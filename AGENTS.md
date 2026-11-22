# AGENTS.md · FPGA / Verilog 中文教程的维护规范

## 北极星
将本仓库维护成准确、可独立阅读、可验证的硬件设计教材。一个从未读过本仓库的读者应当能够从任一章单独开始，读懂问题、前置概念、电路机制、示例代码、验证步骤和局限性。不要写“本讲义介绍了……”，不要宣称无法核验的“真实踩坑经历”。

## Olah-style-posts 的实施约束
参考 https://github.com/1998x-stack/Olah-style-posts/blob/main/skills/olah-style-paper-posts/SKILL.md 的问题驱动、由简到繁、可视化证据链与可复现实验；不复制他人作品。
每章按以下顺序写作：具体现象/反例 → 最小逻辑模型 → 信号流与时钟波形 → 精确 Verilog → 运行和验证 → 适用条件与边界 → 一手参考。
新增 SVG 应为独立文件，包含 xmlns、viewBox、title、desc；每张图只能表达可由正文验证的机制，色彩、信号名、位宽、箭头方向保持一致。禁止装饰性假图。
每章只有一个 H1，严格按照 H2/H3 层级；正文不出现“SVG/CSS/AI 生产过程/Olah 风格”之类的制作说明。
宽度 360 / 390 / 1440px 逐页验证文本溢出、图片、键盘焦点、链接、代码块与交互；未经实际测试不得写“通过浏览器验收”。

## 技术审计
- 分清 IEEE Verilog 语言语义、仿真事件调度、综合推断、约束后的时序以及 FPGA 厂商专用原语。不能从一段 RTL 唯一推断门数、频率或芯片功耗。
- 明确 Verilog-2005 与 SystemVerilog 的差别（如 reg 不等同于物理寄存器、always @* 与 always_comb）。
- 每次涉及阻塞/非阻塞赋值、四态值、延迟、亚稳态、毛刺等，写出发生条件、时钟周期和可运行的示例。
- 任何统计值、厂商版本、器件特性、时序数字均需一次性来源验证；不编造经验故事、实现报告、基准数据。
- 第一手参考：IEEE 1364/1800、AMD UG474、Altera Quartus 推荐设计文档、Icarus Verilog 官方文档；厂商系列/版本必须标注。

## 路径契约
- `index.html` 是 GitHub Pages 唯一门户。
- `chapters/01.html` 到 `chapters/28.html` 为规范章节；根目录同名路径是兼容跳转，**不得删除**。
- `assets/css/site.css` 维护首页，`assets/css/article.css` 维护重写文章，`assets/svg/` 保存全部独立图，`assets/js/` 为渐进增强交互。
- `chapters/theme.css` 是 11–28 章迁移期的兼容样式；不要求一轮强行重写所有课程。
- `data/` 存储课程目录、证据账本；`examples/rtl/` 与 `examples/tb/` 放可综合样例及自检 testbench；`scripts/` 与 `.github/workflows/` 是验收和发布入口。

## 每一篇完成定义
1. 问题、图解、信号含义、代码与正确性条件均独立完整；
2. 至少一个自绘专用 SVG，有可独立理解的图题、清晰字体和标注；
3. 代码类型、端口宽度、复位语义、采样时刻与说明一一对应；
4. 有小规模确定性验算或列出具体操作步骤和预期现象；
5. 有一手来源 URL，并说明设备相关断言范围；
6. 通过 `python3 scripts/check_site.py`、相应 iverilog testbench、GitHub Actions；
7. 如果使用浏览器验收，应记录实际截图和未覆盖场景；对未执行测试如实说明；
8. 维护首页、README、旧链接的兼容性。

## 第二阶段协议模块的最小交付边界
- `uart_tx.v`/`uart_rx.v` 只实现 8N1、整数 bit divider、单字节，无 FIFO/校验/硬件流控。
- `spi_master_mode0.v` 只支持 CPOL=0、CPHA=0；禁止称为四模式 SPI Master。
- `i2c_bit_cell.v` 仅为单个 bit 的 data/SCL 时序单元，无 START/STOP/ACK/多主仲裁；示例顶层需明确开漏输出与管脚上拉。
- 将 24LC256 的内部写周期忙碌与一般 I²C stretching 分开：官方数据手册的 ACK polling 是 NACK 检测，不得编造该器件将 SCL 长时间拉低。
- CI 必须运行 `bash scripts/run_rtl_tests.sh`；浏览器覆盖首页与 01—10。
