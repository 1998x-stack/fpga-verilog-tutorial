# 第五批 21–25 技术复审与验收记录

| 章节 | 原版风险 / 易错点 | 本轮重构与证据 | 可验证边界 |
|---|---|---|---|
| 21 RISC-V | 把 ISA 和五级流水线混为一谈；B/J 立即数切片错误；把跑程序当作合规 | 按 RV32I 2.1 重写 R/I/S/U 与 B/J immediate；新增 immediate generator、forwarding/load-use hazard unit 和自检 | 仅验证子模块，不是完整 CPU、ACT 认证或板级运行 |
| 22 SerDes | PCIe Gen5/Gen6 混淆；将 GTY/GTH 速率泛化；把协议吞吐当作线速率 | 按 PCI-SIG 区分 Gen1/2 8b10b、Gen3–5 128b130b NRZ、Gen6 PAM4/FLIT/FEC；增加 NRZ 链路预算工具 | 仅计算线编码上界，不模拟 PAM4、FEC、PHY 或实际吞吐 |
| 23 调试 | 将 ILA/VIO 视为相同工具；给出未经测量的 probe 资源和时序损失数字；JTAG 当作实时控制 | 按 AMD UG908 / Intel Signal Tap 资料区分采样、触发、慢速控制；新增饱和事件计数器 | RTL 自检通过，不代表真实 ILA/SignalTap 捕获 |
| 24 开源工具 | 夸大 Yosys SystemVerilog 支持和 nextpnr Xilinx 支持；声称“生产级/完美支持”；虚构工具基准 | 更新 Yosys frontend 说明；按 nextpnr upstream README 标记 Nexus alpha、Cyclone V/MachXO2/Xilinx 7-Series experimental，并说明 NG-Ultra bitstream 依赖专有 Impulse；新增 iCEstick HX1K/TQ144 Makefile | CI 只检查命令与 PCF 静态契约，不声称 bitstream 或上板 |
| 25 时序功耗 | 用固定逻辑级数、功耗比例或 WNS 数字做通用结论；把 false path 当作修复 | 解释 setup/hold、skew、WNS/TNS、约束完整性、CE 时钟门控和 activity-based power；新增教学计算器 | 不调用真实 STA / power engine，不报告器件 Fmax 或 mW 实测 |

## 新增可执行资产
- `rv32i_frontend_units.v` + `tb_rv32i_frontend_units.v`
- `debug_event_counter.v` + `tb_debug_event_counter.v`
- `scripts/serdes_budget.py` + 单元测试
- `scripts/timing_power_budget.py` + 单元测试
- `examples/open-source/ice40/` iCEstick Yosys/nextpnr/icepack flow
- 15 张章节 SVG；HTML 页面均独立成文并保留旧 URL redirect

## CI 结论范围
15 组 Icarus testbench、Python unittest、HTML/local-link/SVG 静态检查、开源示例静态契约和 Playwright 首页 + 01—25 页面检查。没有运行厂商 EDA、生成真实 bitstream、连接 FPGA、测量 SerDes 误码、捕获 ILA 波形、或完成真实 STA/power sign-off。
