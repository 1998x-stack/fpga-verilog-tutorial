# FPGA / Verilog 教程：从逻辑到硬件系统

[教程首页](https://1998x-stack.github.io/fpga-verilog-tutorial/) · [从第一章开始](chapters/01.html) · [协作规范](AGENTS.md)

28 章中文 FPGA / Verilog 教程：硬件架构、数字逻辑、Verilog 语言、FSM、仿真、通信接口、RAM、流水线、CDC、时序分析、EDA 工具、总线、处理器、HLS 和综合项目。

**当前重构范围：01—28 全部章节。** 每章均按同一规范重写：具体问题、最小模型、独立 SVG、精确 Verilog、可运行验证、适用边界与一手来源。Pages 链接需仓库启用 GitHub Actions 发布源并部署成功后才能访问。

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
scripts/check_site.py         # HTML/链接/SVG 静态检查
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
bash scripts/run_rtl_tests.sh                  # 12 组 Icarus Verilog 自检
python3 scripts/check_site.py                  # 全站链接与 SVG
python3 -m unittest discover -s tests -p 'test_sta_budget.py' -v
python3 scripts/check_vivado_example.py        # 仅检查脚本契约
python3 scripts/browser_check.py               # 需要 Playwright + Chromium
```

[AMD Vivado 2026.1+ 许可层级](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado/vivado-licensing-options.html)：免费 BASIC 同时列有 Windows/Linux 支持，设备/功能和续期条件以最新官方表格为准。不能沿用“Linux 完全取消免费授权”的原文断言。
