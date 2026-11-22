# FPGA / Verilog 教程：从逻辑到硬件系统

[教程首页](https://1998x-stack.github.io/fpga-verilog-tutorial/) · [从第一章开始](chapters/01.html) · [协作规范](AGENTS.md)

28 章中文 FPGA / Verilog 教程：硬件架构、数字逻辑、Verilog 语言、FSM、仿真、通信接口、RAM、流水线、CDC、时序分析、EDA 工具、总线、处理器、HLS 和综合项目。

**当前重构范围：01—25。** 26—28 篇仍保留原版正文，后续逐章技术审计。GitHub Pages 由 main 分支的 Actions 工作流发布。

## 五阶段学习路径
1. 01—05：数字硬件、时钟和 Verilog 逻辑基础
2. 06—10：时序电路、FSM、Testbench、UART/SPI/I²C
3. 11—14：RAM/FIFO、流水线、CDC、静态时序分析
4. 15—20：Vivado、Quartus、IP、工程组织、AXI、软核
5. 21—28：RISC-V、SerDes、调试、优化、HLS 和系统项目

## 目录
```text
index.html                     # GitHub Pages 入口
01.html ... 28.html            # 根目录旧 URL 的兼容页
chapters/01.html ... 28.html   # 规范章节
chapters/theme.css            # 迁移期兼容老章节
assets/css/                   # 首页与文章样式、保留旧样式
assets/svg/                   # 独立 SVG
assets/js/                    # 渐进增强的导航搜索
data/                         # 课程数据、技术资料/证据
examples/rtl/ examples/tb/    # 可运行逻辑和 testbench
sim/questa/                    # Questa-Altera 本地仿真脚本
examples/quartus/              # Quartus 工程与 SDC 示例
examples/softcore/             # MicroBlaze V SoC 与 MMIO 固件示例
examples/project-template/     # 工程结构与版本清单模板
scripts/check_site.py         # HTML/链接/SVG 静态检查
scripts/serdes_budget.py      # NRZ 线编码链路预算上界
scripts/timing_power_budget.py # 教学版 Setup / 动态功耗算术
scripts/build_manifest.py      # 源输入 SHA-256 清单
.github/workflows/            # CI 与 Pages
AGENTS.md                     # 内容与工程规范
```

## 预览和验证
```bash
python3 -m http.server 8000
# 打开 http://localhost:8000/
python3 scripts/check_site.py
# 需要安装 Icarus Verilog
iverilog -g2012 -Wall -s tb_mux4 -o /tmp/mux4.vvp examples/rtl/mux4.v examples/tb/tb_mux4.v && vvp /tmp/mux4.vvp
iverilog -g2012 -Wall -s tb_alu4 -o /tmp/alu4.vvp examples/rtl/alu4.v examples/tb/tb_alu4.v && vvp /tmp/alu4.vvp
```

## 内容审查与依据
写作采用 [Olah-style-posts](https://github.com/1998x-stack/Olah-style-posts) 的渐进解释方法，新图解独立绘制。技术资料优先采用 [AMD UG474](https://docs.amd.com/r/en-US/ug474_7Series_CLB)、[Altera Quartus 设计推荐](https://docs.altera.com/r/docs/683323/18.1/quartus-prime-standard-edition-user-guide-design-recommendations/avoid-unintentional-latch-generation) 与 [Icarus Verilog](https://steveicarus.github.io/iverilog/) 官方文档。有关迁移原则详见 [docs/migration.md](docs/migration.md)。

## 第二批可运行实验（06—10）

`bash scripts/run_rtl_tests.sh` 运行八组自检，包括模 N 计数器、消抖、重叠 101 FSM、UART 8N1 TX/RX 回环、SPI Mode 0 回环与 I²C 单 bit 等待 SCL 释放/超时（不是完整 I²C 主机）。

教学简化与工程边界详见各章。I²C 的 24LC256 写周期应按 [Microchip Datasheet](https://www.microchip.com/content/dam/mchp/documents/MPD/ProductDocuments/DataSheets/24AA256-24LC256-24FC256-Data-Sheet-20001203W.pdf) 执行 ACK polling，而不是把地址 NACK 误写成 SCL stretching。

## 第三批（11—15）：存储、流水、CDC、STA、Vivado

- **11 RAM / FIFO：** `ram_sp_read_first.v` 明确单端口同址读旧值；`sync_fifo.v` 使用 count 空满逻辑，满时同拍读写只接受读、空时只接受写。双时钟同址碰撞可能不确定，不得宣称 read-first 能消除。
- **12 流水线：** `pipe3_calc.v` 无符号 `(x+7)×3` 的三个寄存阶段，输入于 E0 采样、E2 输出；数据与 valid 同步前进，CE 停顿须由消费者一起遵守。
- **13 CDC：** `cdc_toggle_event.v` 是带回传 ACK 的单 bit 事件跨域，不是宽总线 FIFO。Gray FIFO 额外需要独立约束、CDC/STA 检查，不能盲目 false path。
- **14 STA：** `scripts/sta_budget.py` + `tests/test_sta_budget.py` 提供简化 Setup/Hold 算术和单元测试，不调用真实时序引擎。`examples/timing/interface_example.xdc` 数值完全是示意，不能用于真实板卡。
- **15 Vivado：** `examples/vivado/build.tcl` 和 `blink_top.v`，必须自行提供真实 `FPGA_PART` 和 `BOARD_XDC`。未安装 Vivado/缺少板卡时仅运行静态 Tcl 契约检查，不能宣称生成 bitstream。

```bash
bash scripts/run_rtl_tests.sh                  # 15 组 Icarus Verilog 自检
python3 scripts/check_site.py                  # 全站链接与 SVG
python3 -m unittest discover -s tests -v        # STA + Build Manifest 单元测试
python3 scripts/check_quartus_example.py       # 仅检查 Quartus 工程模板
python3 scripts/check_vivado_example.py        # 仅检查 Vivado Tcl 契约
python3 scripts/check_open_source_example.py    # 仅检查 iCEstick 工具链契约
python3 scripts/browser_check.py               # 需要 Playwright + Chromium
```

[AMD Vivado 2026.1+ 许可层级](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado/vivado-licensing-options.html)：免费 BASIC 同时列有 Windows/Linux 支持，设备/功能和续期条件以最新官方表格为准。不能沿用“Linux 完全取消免费授权”的原文断言。

## 第四批（16—20）：Quartus、Questa、IP、AXI 与软核 SoC

- **16 Quartus / TimeQuest：** `examples/quartus/` 提供通用计数器 RTL、50 MHz 教学 SDC 和 Tcl 项目生成脚本。必须传入真实 `FPGA_FAMILY` / `FPGA_DEVICE`；示例没有板卡 pin map，不可直接下载。
- **17 Questa：** `sim/questa/run.do` 编译并仿真第 19 章 AXI4-Lite 外设。当前 Altera 模拟器为 Questa-Altera FPGA Edition；Starter Edition 免费，但仿真需要 no-cost license。公共 CI 使用 Icarus，不声称运行了 Questa。
- **18 IP Core / Platform Designer：** 解释 Avalon、AXI、AXI-Lite、AXI-Stream 接口契约，IP Packager 的 VLNV、clock/reset、地址块和版本依赖；同时给出工程目录、Git 忽略边界与 `scripts/build_manifest.py` SHA-256 输入清单。
- **19 AXI4-Lite：** `axi4lite_regs.v` 是 32-bit、单 outstanding 的教学 subordinate；AW/W 独立握手，支持 WSTRB、B/R 背压、只读寄存器与 SLVERR；自检覆盖不同通道到达顺序。
- **20 MicroBlaze V：** 以 2026.1 文档中的 RISC-V MicroBlaze V 为主线，提供 SoC 集成契约与 MMIO C 示例。IP Integrator、XSA、Vitis 和真实地址映射需要在目标板工具环境完成。

本批的 RTL 仿真通过不等于 Quartus/Questa/Vivado 工具构建，也不等于 FPGA 上板验证。真实器件、管脚、时钟、IP 许可与软件 BSP 必须由使用者按具体板卡配置。


## 第五批（21—25）：RISC-V、SerDes、调试、开源工具与时序功耗

- **21 RV32I：** `examples/rtl/rv32i_frontend_units.v` 提供 I/S/B/U/J 立即数生成器、EX/MEM 优先的 Forwarding 和 load-use stall；`tb_rv32i_frontend_units.v` 对编码与冒险规则做定向自检。它不是完整 CPU。
- **22 SerDes：** `scripts/serdes_budget.py` 计算 NRZ 线编码后的单向吞吐上界；正文区分 PCIe Gen1/2 8b/10b、Gen3–5 128b/130b NRZ 和 Gen6 PAM4/FLIT/FEC。
- **23 调试：** `debug_event_counter.v` 提供同域饱和事件计数器；正文覆盖 ILA、SignalTap、VIO、JTAG-to-AXI、采样时钟和 probe 成本。
- **24 开源工具：** `examples/open-source/ice40/` 给出 iCEstick + iCE40-HX1K-TQ144 的 Yosys / nextpnr / icepack Makefile。CI 只检查命令和引脚契约，不声称生成 bitstream 或完成板级测试。
- **25 时序与功耗：** `scripts/timing_power_budget.py` 提供简化 setup slack 和动态功耗公式；不替代 Vivado/TimeQuest STA 或器件功耗分析。

本批新增 15 幅 SVG、2 组 RTL 自检、2 个 Python 计算工具和一个 iCEstick 构建入口。15 组 Icarus 回归、Python 单元测试、静态 HTML/SVG 检查与 Playwright 浏览器检查只对各自覆盖范围负责；真实 CPU、SerDes、ILA、bitstream、时序和功耗测量仍需目标器件及厂商工具/硬件。
