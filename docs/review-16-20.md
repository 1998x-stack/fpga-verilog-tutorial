# 第四批 16–20 技术复审记录

| 章节 | 旧内容风险 | 本轮修正 | 验证边界 |
|---|---|---|---|
| 16 Quartus | 将器件/板卡、Edition 能力和工具流程写成通用事实；QSF 与 SDC 责任混淆 | 以官方 Quartus / TimeQuest 文档为依据，分开工程设置与时序约束；Tcl 需要真实 family/part | 仅提供通用项目生成器与静态检查，不声称运行 Quartus/Fitter |
| 17 Questa | 继续使用过时 ModelSim 默认称呼，遗漏 Starter license 条件 | 采用 Questa-Altera FPGA Edition 当前名称，明确免费 Starter 仍需 no-cost license；说明 compile/elaborate/simulate | CI 只运行 Icarus；Questa do 文件留给已安装并配置 license 的本地环境 |
| 18 IP Core / Platform Designer | 将 IP 当成单一 RTL 文件，忽略接口元数据、clock/reset、VLNV 与协议转换 | 增加 IP Packager、Platform Designer / IP Integrator、接口桥、版本管理和可复现目录；保留 QSF/SDC/XPR/IP 配置等输入 | 提供封装与系统契约，不声称已经生成 vendor IP archive；manifest 只追踪输入，不承诺 bitwise identical bitstream |
| 19 AXI4 | 容易把五通道握手写成同拍联动，未完整覆盖 AW/W 独立到达和背压 | 依据 Arm IHI 0022H 实现 32-bit 单 outstanding AXI4-Lite subordinate；独立 AW/W buffer、WSTRB、B/R hold、SLVERR | Icarus testbench 覆盖 AW-first、W-first、同时到达、字节 strobe 和 B/R backpressure；不等于 AXI VIP 或形式验证 |
| 20 Softcore | 混淆 classic MicroBlaze 与 RISC-V MicroBlaze V，使用无来源资源/频率/DMIPS 数字 | 采用 MicroBlaze V 2026.1 RISC-V 文档；解释 LMB、AXI、地址映射、XSA/Vitis 和 MMIO | 提供系统契约与 C 示例，不声称生成 XSA/ELF 或上板成功 |

## 当前新增证据
- 15 幅章节专用 SVG，另加 AXI4-Lite register map。
- `axi4lite_regs.v` + `tb_axi4lite_regs.sv`。
- `sim/questa/run.do` 与本地授权说明。
- Quartus Tcl 工程模板与 TimeQuest 教学 SDC。
- IP Packager / Platform Designer 两张 SVG、Project template、SHA-256 Build Manifest 与 Python 单元测试。
- MicroBlaze V system contract 与 Vitis MMIO C 示例。

## CI 只对以下范围作出结论
Icarus RTL regression、Python 单元测试、HTML/SVG/本地链接静态检查、Quartus/Vivado 示例静态契约、Playwright 页面验收。未执行真实 Quartus、Questa、Vivado、XSA、ELF 或 FPGA 板级构建。
