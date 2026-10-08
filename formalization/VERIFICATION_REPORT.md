# Lean 4 验证报告

GitHub 发布说明：此报告记录原始验证运行；原始 `logs/` 未随源码上传，文中日志路径可在本机原始归档中查阅。

原始验证项目：`autocorrelation_lean/`。验证日期：2026-09-17。

**六个原分析目标均已有真实 theorem。39 个工程模块已完成干净重建；完整 `lake build`、`lake env lean Audit.lean` 与 `scripts/check.ps1` 均返回 0。25 项公理检查全部只依赖标准三公理。最终复验于 2026-09-17 12:46:29（北京时间）完成。**

本报告分开确认 Python 精确检查、Lean 有限证书、Lean 分析定理和工程复验。当前结果不表示论文所有后续推论均已形式化。

## 1. 工具链、版本与依赖

已从官方 Lean GitHub release 下载并安全解压 Windows x64 预编译包，实际执行结果为：

```text
Lean (version 4.19.0, x86_64-w64-windows-gnu, commit 6caaee842e94, Release)
Lake version 5.0.0-6caaee8 (Lean version 4.19.0)
```

`lake --version`、`lake env lean --version`、`lake update` 都已真实运行成功。mathlib 固定为官方 `v4.19.0` 提交 `c44e0c8ee63ca166450922a373c7409c5d26b00b`。`lake-manifest.json` 锁定全部依赖；`logs/current-run/dependency-revisions.json` 记录来源及提交，`dependency-final-check.json` 再次确认 9 个实际 Git HEAD 全部与锁一致。

mathlib 唯一已跟踪修改为 `Cache/IO.lean` 的 `leantar --jobs 1` 工具补丁，与 `scripts/patches/mathlib-cache-single-worker.patch` 精确一致。其余依赖无已跟踪修改；没有改动数学库声明、证明或缓存校验。Lake 关于 mathlib 存在本地修改的警告来自这个已记录补丁。

官方 Lean 压缩包 SHA-256：`2c197a74b6d9c4d46363e34e06591165ed848237ba66de849f8b8d5539eb3895`。官方 API 对此旧资产没有提供 digest，此哈希仅用于追踪，不是独立来源认证。系统 curl 首次遇到 `CRYPT_E_REVOCATION_OFFLINE`；随后使用默认 TLS 验证的 Python HTTPS 客户端取得官方包。未关闭 TLS 校验，未修改系统 DNS、全局代理或全局 Lean 默认版本。

## 2. 分层验收与实际证据

以下名称均位于 `logs/current-run/`；每个命令的 `.json` 保存真实退出码、argv、时间和资源数据，`.log` 保存本次原始输出。

| 检查 | 实际结果 | 证据 |
|---|---|---|
| `lake update` | 退出码 0 | `20260917T035550.166862Z_lake-update-final.*` |
| 按需 `lake exe cache get` | 退出码 0 | `20260917T040510.723052Z_lake-cache-bounded.*` |
| Python 原始 Bernstein 精确检查 | 退出码 0 | `20260917T040455.425908Z_python-bernstein.*` |
| Python 独立重叠积分 / Sturm | 退出码 0 | `20260917T040456.052964Z_python-independent-sturm.*` |
| Python 生成证书及坏系数反向测试 | 退出码 0 | `20260917T040458.678143Z_python-generated-audit.*` |
| Lean 有限证书依赖模块 | 25 个模块串行通过 | `20260917T041643.264777Z_serial-build.json` |
| 有限证书七项公理审计 | 退出码 0，仅标准公理 | `20260917T042308.976577Z_finite-axioms.*` |
| 完整工程模块 | 39 个模块串行通过 | `20260917T043233.389605Z_serial-build.json` |
| 完整 `lake build` | 退出码 0 | `20260917T043609.661078Z_lake-build-first-complete.*` |
| `lake env lean Audit.lean` | 退出码 0，25 项公理输出；六项原类型断言通过 | `20260917T043613.789909Z_all-core-axioms.*` |
| 重新生成一致性检查 | 退出码 0，比较对象无散列变化 | `20260917T043637.696480Z_regeneration-final.*`、`regeneration-check.json` |
| 九项依赖及补丁复核 | 退出码 0 | `20260917T043638.831853Z_dependency-final.*`、`dependency-final-check.json` |
| 干净重建与 `check.ps1` | **退出码 0，全部 39 个模块重新编译通过** | `20260917T043659.9394903Z_clean-check.*`、`20260917T043704.221553Z_serial-build.json` |
| 干净重建后完整 `lake build` | 退出码 0 | `20260917T044601.456456Z_check-lake-build-83529d45ae784138ab8f4e00b611f7b9.*` |
| 干净重建后 `Audit.lean` | 退出码 0，25 项仅标准公理，六原类型断言通过 | `20260917T044605.609856Z_check-lean-audit-83529d45ae784138ab8f4e00b611f7b9.*` |
| 绑定实际审计元数据的公理解析 | 退出码 0，完整覆盖 25 项 | `20260917T044629.032820Z_check-axiom-parser-83529d45ae784138ab8f4e00b611f7b9.*` |

Python 检查是独立精确算术审计，没有作为 Lean 的外部成功标志或证明公理。原程序的 `actual L1 function ratio` 字样也没有被当作分析定理证明。真实 Lean 日志和 `#print axioms` 才构成本轮相应形式化验收证据。

## 3. 有限证书通过范围

20 个 Bernstein 子区间和 367 个非负整数系数的恒等式、非负性及覆盖拼接均实际编译通过，得到 `DP_nonnegative_on_interval`、四段相关多项式下界和 `finite_certificate`。证明覆盖连续区间，没有用浮点近似或采样替代。

早期 `FiniteAudit.lean` 实际审计的七项是：`finite_certificate`、`P_matches_paper`、`DRR_identity`、`g0_expansion`、`g1_expansion`、`g2_expansion`、`g3_expansion`。每项输出均为 `[propext, Classical.choice, Quot.sound]`。其后实际分段积分桥接也已完成，有限代数证书已经通过已证明的分析定理接到普通函数结论。

## 4. 六个分析目标

| 原目标 | 实际 theorem | 状态与公理依赖 |
|---|---|---|
| `OverlapIntegralClaim` | `Autocorrelation.overlap_integral` | 已证明、编译、公理审计；仅标准三公理 |
| `WitnessAdmissibilityClaim` | `Autocorrelation.witness_admissibility` | 已证明、编译、公理审计；仅标准三公理 |
| `MassIntegralClaim` | `Autocorrelation.mass_integral` | 已证明、编译、公理审计；仅标准三公理 |
| `UniformCorrelationClaim` | `Autocorrelation.uniform_correlation` | 已证明、编译、公理审计；仅标准三公理 |
| `ExplicitMainClaim` | `Autocorrelation.explicit_main` | 已证明、编译、公理审计；仅标准三公理 |
| `LimitingMainClaim` | `Autocorrelation.limiting_main` | 已证明、编译、公理审计；仅标准三公理 |

六项均已纳入项目导入入口和 `Audit.lean`。审计文件还实际编译了形如 `example : OverlapIntegralClaim := overlap_integral` 的六个原类型断言。因此本次不只是检查 theorem 名称、公理输出或 `def Claim : Prop`，而是核对了六个证明项确实具有原始目标类型，没有额外未证明关键假设。

证明路径包括：分段 Lebesgue 积分与多项式公式对应；`phi` 及见证的非负性、可测性、可积性、平方与任意平移乘积可积性；实际质量积分；整个闭区间 `t∈[0,1]` 上的统一下界（包含两个端点）；显式见证与极限逼近。

## 5. 两个主定理的实际声明与范围

`Autocorrelation/Main.lean` 的声明为：

```lean
theorem explicit_main : ExplicitMainClaim
theorem limiting_main : LimitingMainClaim
```

`ExplicitMainClaim` 的准确内容是：令 `f := witness delta0`，则 `f` 与 `f²` 可积，`f` 处处非负，`∫ f > 0`；对每个 `0 ≤ t ≤ 1`，函数 `x ↦ f x * f (x+t)` 可积，且

```text
explicitRatio ≤ (∫ x : ℝ, f x * f (x+t)) / (∫ x : ℝ, f x)^2。
```

`LimitingMainClaim` 的准确内容是：对每个实数 `q < limitingRatio`，存在一个普通函数 `f : ℝ → ℝ`，满足同样的可积、平方可积、非负与正质量性质，并在整个闭区间上满足上述归一化自相关下界，右侧比较常数换为 `q`。证明使用实际 `witness delta`，没有把原子测度当作普通 L¹ 函数。

证书中的精确参数没有改变：

```text
delta0 = 1/10000000000
explicitRatio = 4713977940944586245580976375978623597750000000000000000 /
                11486917430134691792906455293684961315501879073559791929
limitingRatio = 4713977940944586245580976375978623597750000000000000000 /
                11486917427785951575611071745219515905862879073559791929
```

两个主定理的实际 `#print axioms` 都是 `[propext, Classical.choice, Quot.sound]`；六个核心定理均没有 `sorryAx`、自定义数学公理或其他额外公理依赖。

**极限结论只验收上述普通函数见证表述。工程没有定义论文常数 `A` 为某个可行集的 `sSup`，也没有形式化这个上确界定义与当前见证表述的等价关系。** 本工程没有宣称论文全部后续推论、弱收敛/Fourier/广义差基推论、完全稀疏尺问题或 Erdős #170 已形式化证明。

## 6. 修改、复现与可信性

真实编译中遇到的语法、类型、隐式参数、非负性推理和库接口错误均按实际错误修复。原大型模型拆分为 `Profile`、`PrimitivePolynomials`、`CorrelationModel`、`DerivativeAlgebra`、`Derivatives` 等模块以控制内存；原模型导入入口保留。没有删除失败结论、改动精确参数或弱化六个原目标。

新增分析模块为 `Overlap`、`Witness`、`Mass`、`Extension`、`Uniform`、`Main`。生成器已经同步本轮修复；`scripts/verify_regeneration.py` 实际再次运行生成器，确认 `Autocorrelation/` 下所有现存 Lean 源码及 `bernstein_leaves.json` 的 SHA-256 均未改变，详见 `regeneration-check.json`。这项复现检查不替代 Lean 编译。

`scripts/verify_specification.py` 已实际读取原输入 ZIP 比较，退出码 0；`logs/current-run/specification-check.json` 记录 `Targets.lean` 的全部 12 个定义去除注释和空白后完全一致，证书字节不变、两个精确比值一致、六个审计类型绑定存在。它是源码一致性检查；六个证明项的实际类型仍由 Lean 编译核对。

`scripts/verify_dependencies.py` 实际检查 Git 提交与 manifest、官方 mathlib 标签及唯一工具补丁。`scripts/check_axioms.py` 检查 25 项实际公理输出，并可将日志绑定到成功的 Lean 命令元数据；六个原命题的类型由 `Audit.lean` 中实际通过的断言验证。词法扫描仅为辅助检查。

Windows 复现入口：

```powershell
. .\scripts\env.ps1
.\scripts\prepare_cache.ps1
.\scripts\clean_check.ps1
```

`clean_check.ps1` 验证绝对路径后，将仅本项目 `.lake/build` 移入项目内备份，保留匹配版本的依赖缓存，记录源码/配置散列并执行 `check.ps1`。`check.ps1` 按依赖顺序串行构建模块，再真实执行完整 `lake build`、`lake env lean Audit.lean` 和严格公理检查。无需清理时可直接执行 `scripts/check.ps1`。

`scripts/run_logged.py` 保留每条命令的完整输出、真实退出码及资源峰值；`build_serial.py` 支持指定模块及其依赖。编排脚本应直接调用，不能额外套一层 `run_logged.py` 而嵌套单命令锁。

## 7. 资源记录与剩余事项

本机约 16 GB 内存。编译使用低优先级、两核、Lean 单线程与内存监控；达到 90% 只停止本次进程树。首次完整缓存请求实际触发内存保护（约 90.16%，状态 `memory_limit`），失败日志保留。后续按需缓存请求成功，耗时约 424 秒、峰值系统内存约 82.49%。

现有系统代理仅继承到当前进程；curl 设置连接超时 15 秒、单次传输最大 120 秒及最多 8 个网络 I/O 并发。编译及解包为单任务。官方 leantar 来源及散列在 `leantar-provenance.json`。

六个目标及本次工程验收没有剩余阻塞。干净重建与 `check.ps1` 已实际返回 0，其完整记录为 `20260917T043659.9394903Z_clean-check.*`；构建前项目 `.lake/build` 已移走，九项匹配依赖缓存保留。最终原始输出也便捷汇总到 `logs/lean-build.log`、`logs/lean-axioms.log`、`logs/lean-version.txt`，公理解析结果在 `logs/lean-axiom-status.json`。整篇论文超出六个原目标的部分仍在当前验收范围之外。

源码 ZIP 包含全部修改后源码、原论文与证书、锁定依赖清单、运行脚本、历史与本轮日志。本机 `.tools/` 与 `.lake/` 中的已安装工具链、缓存及旧构建备份继续保留；这些可重建目录不重复压入源码包。打包脚本再次核对所有已审计 Lean 源码和锁文件的散列，并生成文件级校验清单。
