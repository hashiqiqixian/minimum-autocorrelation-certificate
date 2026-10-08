# 最小自相关证书：Lean 4 形式化工程

GitHub 发布说明：以下文字记录原始验证归档的状态。仓库保留完整源码、证书、脚本和报告，但不包含原始 `logs/`、本机 `.tools/`、`.lake/` 缓存及旧版生成 PDF。复现时须自行准备 Lean 4.19.0 和相应依赖；文中的历史日志路径对应本机原始归档，不是此仓库中的文件。

交付源码包 `autocorrelation_lean_verified.zip` 包含完整项目源码、证书、锁文件、脚本和真实日志；可重建的 `.tools/` 工具链及 `.lake/` 依赖缓存保留在本机工作目录，不重复装入源码 ZIP。`scripts/package_project.py` 仅允许在干净复验通过、源码散列与复验前一致后打包，并生成 `SHA256SUMS.txt` 与 ZIP 的 SHA-256。

**六个原分析目标、显式普通函数定理和极限函数见证定理已真实编译通过。39 个模块已完成干净重建，完整 `lake build`、`Audit.lean` 与 `check.ps1` 均返回 0；25 项公理审计仅含标准三公理。**

实际环境为 Windows x64、Lean `4.19.0`、Lake `5.0.0-6caaee8`、mathlib 官方 `v4.19.0`。完整证据和边界见 `VERIFICATION_REPORT.md`、`STATUS.json`，本轮日志在 `logs/current-run/`。输入包中缺少 Lean、DNS 失败的旧容器记录不代表本轮环境。

## 已证明内容

| 原目标 | 实际 theorem |
|---|---|
| `OverlapIntegralClaim` | `overlap_integral` |
| `WitnessAdmissibilityClaim` | `witness_admissibility` |
| `MassIntegralClaim` | `mass_integral` |
| `UniformCorrelationClaim` | `uniform_correlation` |
| `ExplicitMainClaim` | `explicit_main` |
| `LimitingMainClaim` | `limiting_main` |

所有 theorem 位于 `Autocorrelation` 命名空间，实际公理依赖均为 `propext`、`Classical.choice`、`Quot.sound`。`Audit.lean` 还包含六个实际通过的原 Claim 类型断言；这些结果不是单纯定义命题或打印名称。

有限证书包含 20 个 Bernstein 子区间和 367 个非负整数系数。真实分析证明连接了分段 Lebesgue 积分、非负可积的普通函数、质量积分、包含 `t=0` 与 `t=1` 的统一自相关下界，以及显式和极限结果。Python 精确检查独立重跑通过，没有作为 Lean 证明的外部成功假设。

`limiting_main` 证明：每个 `q < limitingRatio` 都有满足条件的普通实函数见证。**本项目未将论文常数 `A` 定义为可行集的 `sSup`，未证明该上确界定义的等价关系，也没有宣称论文所有后续推论、完全稀疏尺问题或 Erdős #170 已解决。**

## 精确输入与依赖

`original/` 保留原稿和程序，`certificate.json` 的 SHA-256 为 `e9b58a1068baa81723e55ad01640260118ce156ac23c07332cefefc46f552d79`。

- `a = 626600210121/1000000000000`
- `b = 40047498753/250000000000`，`w = 1-2b`，`c = 1-b`
- `gamma = 99999999/100000000`
- `delta0 = 1/10000000000`

```text
explicitRatio = 4713977940944586245580976375978623597750000000000000000 /
                11486917430134691792906455293684961315501879073559791929
limitingRatio = 4713977940944586245580976375978623597750000000000000000 /
                11486917427785951575611071745219515905862879073559791929
```

Lean 提交为 `6caaee842e94`；mathlib 提交为 `c44e0c8ee63ca166450922a373c7409c5d26b00b`。`lake-manifest.json` 锁定全部 9 个依赖。`logs/current-run/dependency-final-check.json` 确认实际提交与锁相符；唯一已跟踪补丁是缓存工具的 `leantar --jobs 1`，没有改动 mathlib 数学文件。

## 源码结构

- `Profile`、`PrimitivePolynomials`、`CorrelationModel`、`DerivativeAlgebra`、`Derivatives`：原大型模型的精确代数及导数证明，拆分以降低内存；`Model` 保留入口。
- `Bernstein`、`Leaves/`、`FiniteCertificate`：区间证书与非负性拼接。
- `ElementaryAnalysis`、`Ratios`、`AtomRemovalAlgebra`：初等分析、比值与一般比较引理。
- `Targets`：六个原命题的规格定义。
- `Overlap`、`Witness`、`Mass`、`Extension`、`Uniform`、`Main`：实际分析桥接及六个目标的证明。
- `Audit.lean`：25 项公理报告及六项原类型断言；`FiniteAudit.lean` 保留早期有限证书审计。

## Windows 复现

工具已安装在项目 `.tools/`。从项目根目录执行：

```powershell
. .\scripts\env.ps1
.\scripts\prepare_cache.ps1
.\scripts\clean_check.ps1
```

`clean_check.ps1` 将本项目 `.lake/build` 安全移到项目内备份，保留依赖缓存，再执行 `check.ps1`。后者逐模块串行构建，然后实际执行完整 `lake build`、`lake env lean Audit.lean` 和严格 25 项公理检查。无需干净重建时可直接运行 `scripts/check.ps1`。

环境与代理只设置在当前会话/子进程。编译低优先级、两核、Lean 单线程，缓存解包单任务，网络 I/O 最多 8 个并发且有超时。每次命令均保存原始输出、真实退出码与资源记录。编排脚本应直接运行，不要套在 `run_logged.py` 外层造成锁嵌套。

```powershell
python scripts/build_serial.py Autocorrelation.Main
python scripts/build_serial.py --list
```

Linux/macOS 历史入口是 `scripts/check.sh`，本轮没有在那些平台复测；资源监控运行器针对 Windows。

## Python、生成器与依赖复核

```powershell
python scripts/run_logged.py --label python-bernstein --timeout 120 --memory-estimate-mb 128 -- python original/verify.py certificate.json
python scripts/run_logged.py --label python-independent-sturm --timeout 300 --memory-estimate-mb 256 -- python original/independent_audit.py certificate.json
python scripts/run_logged.py --label python-generated-audit --timeout 300 --memory-estimate-mb 256 -- python scripts/audit_generated.py
python scripts/run_logged.py --label regeneration --timeout 300 --memory-estimate-mb 256 -- python scripts/verify_regeneration.py
python scripts/run_logged.py --label dependencies --timeout 120 --memory-estimate-mb 64 -- python scripts/verify_dependencies.py
```

生成器已与本轮修复同步。`verify_regeneration.py` 实际再次运行生成器，确认 `Autocorrelation/` 目录全部现存 Lean 源码与 `bernstein_leaves.json` 的散列不变；不要在编译过程中并行重跑生成器。`verify_dependencies.py` 检查实际 Git 提交、官方 mathlib 标签以及已记录的唯一补丁。这些检查辅助复现，不能替代 Lean 内核与公理审计。

关键成功日志为 `20260917T043233.389605Z_serial-build.json`、`20260917T043609.661078Z_lake-build-first-complete.*`、`20260917T043613.789909Z_all-core-axioms.*`。最终干净重建与完整检查脚本也返回 0，见 `20260917T043659.9394903Z_clean-check.*`。便捷入口为 `logs/lean-build.log`、`logs/lean-axioms.log`、`logs/lean-axiom-status.json`。
