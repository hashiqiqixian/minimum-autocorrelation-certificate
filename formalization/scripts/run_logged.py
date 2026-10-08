"""Run one bounded Windows command, preserving actual output and exit status.

Example (from the project directory):
  python scripts/run_logged.py --label build --timeout 600 \
      --memory-estimate-mb 2048 -- lake build

The JSON distinguishes the child's real exit code from the runner's status.
Only this runner's process tree is terminated on timeout or resource pressure.
Python 3.9+, standard library only. Logs from earlier invocations are retained.
"""

import argparse
import ctypes
from ctypes import wintypes
from collections import deque
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import threading
import time


ROOT = Path(__file__).resolve().parent.parent
MIB = 1024 * 1024
WORKER_NAMES = {
    "lean.exe", "lake.exe", "leanc.exe", "clang.exe", "clang++.exe",
    "gcc.exe", "g++.exe", "cc1.exe", "cc1plus.exe", "cl.exe", "link.exe",
    "ninja.exe", "make.exe", "cmake.exe", "cargo.exe", "rustc.exe",
    "pytest.exe", "elan-init.exe",
}


class MemoryStatus(ctypes.Structure):
    _fields_ = [("length", wintypes.DWORD), ("load", wintypes.DWORD)] + [
        (name, ctypes.c_ulonglong) for name in (
            "total", "available", "total_page", "available_page",
            "total_virtual", "available_virtual", "extended_virtual")
    ]


class ProcessEntry(ctypes.Structure):
    _fields_ = [
        ("size", wintypes.DWORD), ("usage", wintypes.DWORD),
        ("pid", wintypes.DWORD), ("heap", ctypes.c_size_t),
        ("module", wintypes.DWORD), ("threads", wintypes.DWORD),
        ("parent", wintypes.DWORD), ("priority", wintypes.LONG),
        ("flags", wintypes.DWORD), ("name", wintypes.WCHAR * 260),
    ]


class BasicLimits(ctypes.Structure):
    _fields_ = [
        ("process_time", ctypes.c_longlong), ("job_time", ctypes.c_longlong),
        ("flags", wintypes.DWORD), ("min_working_set", ctypes.c_size_t),
        ("max_working_set", ctypes.c_size_t), ("active_limit", wintypes.DWORD),
        ("affinity", ctypes.c_size_t), ("priority", wintypes.DWORD),
        ("scheduling", wintypes.DWORD),
    ]


class ExtendedLimits(ctypes.Structure):
    _fields_ = [
        ("basic", BasicLimits), ("io", ctypes.c_ulonglong * 6),
        ("process_memory_limit", ctypes.c_size_t),
        ("job_memory_limit", ctypes.c_size_t),
        ("peak_process_memory", ctypes.c_size_t),
        ("peak_job_memory", ctypes.c_size_t),
    ]


def utc_now():
    return datetime.now(timezone.utc).isoformat()


def win_api():
    k = ctypes.WinDLL("kernel32", use_last_error=True)
    signatures = {
        "GlobalMemoryStatusEx": ([ctypes.POINTER(MemoryStatus)], wintypes.BOOL),
        "GetSystemTimes": ([ctypes.POINTER(wintypes.FILETIME)] * 3, wintypes.BOOL),
        "CreateToolhelp32Snapshot": ([wintypes.DWORD, wintypes.DWORD], wintypes.HANDLE),
        "Process32FirstW": ([wintypes.HANDLE, ctypes.POINTER(ProcessEntry)], wintypes.BOOL),
        "Process32NextW": ([wintypes.HANDLE, ctypes.POINTER(ProcessEntry)], wintypes.BOOL),
        "CloseHandle": ([wintypes.HANDLE], wintypes.BOOL),
        "GetCurrentProcess": ([], wintypes.HANDLE),
        "GetProcessAffinityMask": ([wintypes.HANDLE, ctypes.POINTER(ctypes.c_size_t),
                                    ctypes.POINTER(ctypes.c_size_t)], wintypes.BOOL),
        "CreateJobObjectW": ([ctypes.c_void_p, wintypes.LPCWSTR], wintypes.HANDLE),
        "SetInformationJobObject": ([wintypes.HANDLE, ctypes.c_int,
                                     ctypes.c_void_p, wintypes.DWORD], wintypes.BOOL),
        "QueryInformationJobObject": ([wintypes.HANDLE, ctypes.c_int,
                                       ctypes.c_void_p, wintypes.DWORD,
                                       ctypes.c_void_p], wintypes.BOOL),
        "AssignProcessToJobObject": ([wintypes.HANDLE, wintypes.HANDLE], wintypes.BOOL),
    }
    for name, (args, result) in signatures.items():
        getattr(k, name).argtypes = args
        getattr(k, name).restype = result
    return k


def checked(ok):
    if not ok:
        raise ctypes.WinError(ctypes.get_last_error())


def memory_snapshot(k):
    status = MemoryStatus()
    status.length = ctypes.sizeof(status)
    checked(k.GlobalMemoryStatusEx(ctypes.byref(status)))
    return {
        "used_percent": 100.0 * (1 - status.available / status.total),
        "total_bytes": status.total,
        "available_bytes": status.available,
    }


def cpu_snapshot(k):
    def sample():
        values = [wintypes.FILETIME() for _ in range(3)]
        checked(k.GetSystemTimes(*(ctypes.byref(x) for x in values)))
        return [x.dwLowDateTime + (x.dwHighDateTime << 32) for x in values]
    a = sample()
    time.sleep(0.2)
    b = sample()
    idle, kernel, user = [y - x for x, y in zip(a, b)]
    return 100 * (1 - idle / (kernel + user)) if kernel + user else 0.0


def workers(k):
    handle = k.CreateToolhelp32Snapshot(2, 0)
    if handle == ctypes.c_void_p(-1).value:
        raise ctypes.WinError(ctypes.get_last_error())
    result = []
    try:
        entry = ProcessEntry()
        entry.size = ctypes.sizeof(entry)
        more = k.Process32FirstW(handle, ctypes.byref(entry))
        while more:
            if entry.name.lower() in WORKER_NAMES:
                result.append({"pid": entry.pid, "parent_pid": entry.parent,
                               "name": entry.name, "threads": entry.threads})
            more = k.Process32NextW(handle, ctypes.byref(entry))
    finally:
        k.CloseHandle(handle)
    return result


def make_job(k):
    allowed, system = ctypes.c_size_t(), ctypes.c_size_t()
    checked(k.GetProcessAffinityMask(k.GetCurrentProcess(), ctypes.byref(allowed),
                                    ctypes.byref(system)))
    bits = [1 << i for i in range(ctypes.sizeof(allowed) * 8) if allowed.value & (1 << i)]
    affinity = sum(bits[:2])
    if not affinity:
        raise RuntimeError("No usable CPU affinity mask")
    handle = k.CreateJobObjectW(None, None)
    checked(handle)
    limits = ExtendedLimits()
    # AFFINITY | PRIORITY_CLASS | KILL_ON_JOB_CLOSE. No breakaway is permitted.
    limits.basic.flags = 0x10 | 0x20 | 0x2000
    limits.basic.affinity = affinity
    limits.basic.priority = 0x4000  # BELOW_NORMAL_PRIORITY_CLASS
    try:
        checked(k.SetInformationJobObject(handle, 9, ctypes.byref(limits),
                                         ctypes.sizeof(limits)))
    except BaseException:
        k.CloseHandle(handle)
        raise
    return handle, affinity


def child_environment():
    env = os.environ.copy()
    directories = [ROOT / ".tools/lean-4.19.0-windows/bin", ROOT / ".tools/venv/Scripts"]
    env["PATH"] = os.pathsep.join(str(p) for p in directories) + os.pathsep + env.get("PATH", "")
    overrides = {
        "LEAN_NUM_THREADS": "1", "OMP_NUM_THREADS": "1", "MAX_JOBS": "1",
        "CMAKE_BUILD_PARALLEL_LEVEL": "1", "GIT_TERMINAL_PROMPT": "0",
        "PYTHONUTF8": "1", "PYTHONIOENCODING": "utf-8",
        "RAYON_NUM_THREADS": "1",
        "GIT_HTTP_LOW_SPEED_LIMIT": "1024", "GIT_HTTP_LOW_SPEED_TIME": "30",
    }
    if not env.get("GIT_SSH_COMMAND"):
        overrides["GIT_SSH_COMMAND"] = (
            "ssh -o ConnectTimeout=20 -o ServerAliveInterval=15 "
            "-o ServerAliveCountMax=2 -o BatchMode=yes")
    env.update(overrides)
    return env, overrides, directories


def stop_owned_tree(proc, log):
    # The PID is obtained directly from Popen; no unrelated process is selected.
    taskkill = Path(os.environ.get("SystemRoot", r"C:\Windows")) / "System32/taskkill.exe"
    try:
        result = subprocess.run([str(taskkill), "/PID", str(proc.pid), "/T", "/F"],
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                timeout=15, creationflags=subprocess.CREATE_NO_WINDOW)
        log.write(b"\n[runner taskkill]\n" + result.stdout)
        log.flush()
        return {"exit_code": result.returncode,
                "output": result.stdout.decode("utf-8", errors="replace")}
    except Exception as exc:
        return {"error": str(exc)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--timeout", type=float, default=600)
    parser.add_argument("--label", required=True)
    parser.add_argument("--memory-estimate-mb", type=float, default=1024)
    parser.add_argument("--tail-lines", type=int, default=12)
    parser.add_argument("--cwd", type=Path, default=ROOT)
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    argv = args.command[1:] if args.command[:1] == ["--"] else args.command
    if not argv or args.timeout <= 0 or args.memory_estimate_mb < 0 or args.tail_lines < 0:
        parser.error("a command, positive timeout and nonnegative memory/tail values are required")
    if sys.platform != "win32":
        parser.error("this guarded runner is Windows-specific")

    import msvcrt
    log_dir = ROOT / "logs/current-run"
    log_dir.mkdir(parents=True, exist_ok=True)
    name = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ") + "_" + re.sub(r"[^A-Za-z0-9_.-]", "_", args.label)
    log_path = log_dir / (name + ".log")
    meta_path = log_dir / (name + ".json")
    meta = {"label": args.label, "argv": argv, "cwd": str(args.cwd.resolve()),
            "started_utc": utc_now(), "timeout_seconds": args.timeout,
            "memory_estimate_mb": args.memory_estimate_mb, "log": str(log_path),
            "child_exit_code": None, "runner_exit_code": 125, "status": "preflight"}
    started = time.monotonic()
    proc = None
    job = None
    lock = None
    locked = False
    reader = None
    tail = deque(maxlen=args.tail_lines)
    k = win_api()
    print("[runner] log: " + str(log_path), flush=True)
    print("[runner] command: " + subprocess.list2cmdline(argv), flush=True)

    def save_metadata():
        meta_path.write_text(json.dumps(meta, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    with log_path.open("wb", buffering=0) as log:
        try:
            lock = (log_dir / "runner.lock").open("a+b")
            lock.seek(0, 2)
            if lock.tell() == 0:
                lock.write(b"0")
                lock.flush()
            lock.seek(0)
            try:
                msvcrt.locking(lock.fileno(), msvcrt.LK_NBLCK, 1)
                locked = True
            except OSError:
                raise RuntimeError("Another logged command is already running")
            pre = memory_snapshot(k)
            meta["preflight"] = dict(pre, cpu_used_percent=cpu_snapshot(k),
                                     existing_workers=workers(k))
            projected = pre["used_percent"] + 100 * args.memory_estimate_mb * MIB / pre["total_bytes"]
            meta["projected_memory_used_percent"] = projected
            if pre["used_percent"] >= 90 or projected >= 90:
                raise RuntimeError("Memory safety preflight refused command: current %.2f%%, projected %.2f%%" %
                                   (pre["used_percent"], projected))
            if meta["preflight"]["existing_workers"]:
                raise RuntimeError("Existing build/compiler processes found; wait for them before running another command")
            if meta["preflight"]["cpu_used_percent"] >= 95:
                raise RuntimeError("CPU preflight refused command: existing system load is at least 95%")
            job, affinity = make_job(k)
            meta["cpu_affinity_mask"] = affinity
            env, overrides, directories = child_environment()
            meta["environment_overrides"] = overrides
            meta["path_prefix"] = [str(p) for p in directories]
            # Popen on Windows does not reliably use env['PATH'] for executable lookup.
            executable = shutil.which(argv[0], path=env["PATH"])
            if executable is None:
                raise FileNotFoundError("Executable not found on project PATH: " + argv[0])
            meta["resolved_executable"] = executable
            save_metadata()
            proc = subprocess.Popen([executable] + argv[1:], cwd=str(args.cwd), env=env,
                                    stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT,
                                    creationflags=subprocess.BELOW_NORMAL_PRIORITY_CLASS |
                                    subprocess.CREATE_NEW_PROCESS_GROUP)
            meta["pid"] = proc.pid
            checked(k.AssignProcessToJobObject(job, int(proc._handle)))
            meta["status"] = "running"
            save_metadata()

            def read_output():
                try:
                    for line in iter(proc.stdout.readline, b""):
                        log.write(line)
                        tail.extend(line.decode("utf-8", errors="replace").splitlines())
                except (OSError, ValueError) as exc:
                    meta["output_reader_error"] = str(exc)

            reader = threading.Thread(target=read_output, name="command-output", daemon=True)
            reader.start()
            command_started = time.monotonic()
            last_progress = command_started
            peak_percent = pre["used_percent"]
            minimum_available = pre["available_bytes"]
            peak_job = 0
            reason = None
            while True:
                snapshot = memory_snapshot(k)
                peak_percent = max(peak_percent, snapshot["used_percent"])
                minimum_available = min(minimum_available, snapshot["available_bytes"])
                limits = ExtendedLimits()
                checked(k.QueryInformationJobObject(job, 9, ctypes.byref(limits),
                                                   ctypes.sizeof(limits), None))
                peak_job = max(peak_job, limits.peak_job_memory)
                now = time.monotonic()
                if proc.poll() is not None:
                    break
                if snapshot["used_percent"] >= 90:
                    reason = "memory_limit"
                elif now - command_started >= args.timeout:
                    reason = "timeout"
                if reason:
                    meta["termination"] = stop_owned_tree(proc, log)
                    break
                if now - last_progress >= 30:
                    print("[runner] running %.0fs; system memory %.1f%%; job peak %.0f MiB" %
                          (now - command_started, snapshot["used_percent"], peak_job / MIB), flush=True)
                    last_progress = now
                time.sleep(0.25)
            meta["peak_system_memory_used_percent"] = peak_percent
            meta["minimum_system_available_bytes"] = minimum_available
            meta["peak_job_committed_bytes"] = peak_job
            meta["command_elapsed_seconds"] = time.monotonic() - command_started
            # Closing the job also stops any descendants left after their parent exits.
            k.CloseHandle(job)
            job = None
            meta["child_exit_code"] = proc.wait(timeout=15)
            reader.join(timeout=10)
            if reader.is_alive():
                raise RuntimeError("Output reader did not finish after process tree exit")
            meta["status"] = reason or ("passed" if proc.returncode == 0 else "failed")
            meta["runner_exit_code"] = 124 if reason == "timeout" else 125 if reason else proc.returncode
        except BaseException as exc:
            meta["status"] = "interrupted" if isinstance(exc, KeyboardInterrupt) else "runner_error"
            meta["error"] = str(exc)
            log.write(("\n[runner error] " + str(exc) + "\n").encode("utf-8"))
            if proc is not None and proc.poll() is None:
                meta["termination"] = stop_owned_tree(proc, log)
        finally:
            if job is not None:
                k.CloseHandle(job)
            if proc is not None:
                try:
                    meta["child_exit_code"] = proc.wait(timeout=15)
                except subprocess.TimeoutExpired:
                    meta["cleanup_error"] = "Owned child did not exit within cleanup timeout"
                if reader is not None:
                    reader.join(timeout=5)
            meta["finished_utc"] = utc_now()
            meta["elapsed_seconds"] = time.monotonic() - started
            save_metadata()
            if locked:
                lock.seek(0)
                msvcrt.locking(lock.fileno(), msvcrt.LK_UNLCK, 1)
            if lock is not None:
                lock.close()
    for line in tail:
        print(line.encode(sys.stdout.encoding or "utf-8", errors="replace").decode(sys.stdout.encoding or "utf-8"))
    print("[runner] status=%s child_exit_code=%s elapsed=%.2fs" %
          (meta["status"], meta["child_exit_code"], meta["elapsed_seconds"]), flush=True)
    print("[runner] metadata: " + str(meta_path), flush=True)
    if meta.get("error"):
        print("[runner] " + meta["error"], file=sys.stderr)
    return meta["runner_exit_code"]


if __name__ == "__main__":
    sys.exit(main())
