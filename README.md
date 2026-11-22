# FPGA / Verilog 教程：从逻辑到硬件系统

[教程首页](https://1998x-stack.github.io/fpga-verilog-tutorial/) · [从第一章开始](chapters/01.html) · [协作规范](AGENTS.md)

28 章中文 FPGA / Verilog 教程：硬件架构、数字逻辑、Verilog 语言、FSM、仿真、通信接口、RAM、流水线、CDC、时序分析、EDA 工具、总线、处理器、HLS 和综合项目。

**当前重构范围：01—05。** 其他 23 篇仅迁入规范路径，原文保留，后续逐章技术审计。Pages 链接需仓库启用 GitHub Actions 发布源并部署成功后才能访问。

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
