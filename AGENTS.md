# AGENTS.md · FPGA / Verilog 中文教程的维护规范

## 北极星
将本仓库维护成准确、可独立阅读、可验证的硬件设计教材。一个从未读过本仓库的读者应当能够从任一章单独开始，读懂问题、前置概念、电路机制、示例代码、验证步骤和局限性。不要写“本讲义介绍了……”，不要宣称无法核验的“真实踩坑经历”。

## Olah-style-posts 的实施约束
参考 https://github.com/1998x-stack/Olah-style-posts/blob/main/skills/olah-style-paper-posts/SKILL.md 的问题驱动、由简到繁、可视化证据链与可复现实验；不复制他人作品。
每章按以下顺序写作：具体现象/反例 → 最小逻辑模型 → 信号流与时钟波形 → 精确 Verilog → 运行和验证 → 适用条件与边界 → 一手参考。
新增 SVG 应为独立文件，包含 xmlns、viewBox、title、desc；每张图只能表达可由正文验证的机制，色彩、信号名、位宽、箭头方向保持一致。禁止装饰性假图。
每章只有一个 H1，严格按照 H2/H3 层级；正文不出现“SVG/CSS/AI 生产过程/Olah 风格”之类的制作说明。
宽度 360 / 390 / 768 / 1440px 逐页验证文本溢出、图片、键盘焦点、链接、代码块与交互；未经实际测试不得写“通过浏览器验收”。

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
- `chapters/theme.css` 是 26–28 章迁移期的兼容样式；不要求一轮强行重写所有课程。
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
- CI 必须运行 `bash scripts/run_rtl_tests.sh`、`python3 -m unittest discover -s tests -v`、站点静态检查和示例契约检查；浏览器覆盖首页与 01—28，四种宽度，并对新章节的原生 details 与 MathML 做交互/渲染验收。

## 第三批存储、CDC、时序、工具链边界
- `ram_sp_read_first.v` 明确单时钟、同一端口 READ_FIRST 语义；跨端口、跨时钟碰撞必须依据器件原语 datasheet，不得从此例推论。
- `sync_fifo.v` 是单时钟 FIFO；full 下同时读写只读，empty 下同时读写只写。不要直接复用为异步 FIFO。
- `pipe3_calc.v` 是全局 CE 停顿的三个寄存级；data/valid 同步推进，消费者在 ce=0 时不得重复消费；不是 AXI-Stream ready/valid IP。
- CDC：2FF 用于慢变化单 bit 电平，toggle 事件握手用于接受后应答；任意多 bit 总线不可逐位同步替代协议。Gray 总线需 max-delay/bus-skew 约束并检查与异步分组例外的优先级。
- STA 示例 `sta_budget.py` 的所有数字是数学演示。真实 WNS/TNS/时序收敛需具体 FPGA part、工具版本、XDC 和实现报告。
- Vivado：非工程模式须指定真实 `FPGA_PART`、`BOARD_XDC`，不可硬编码虚构引脚、禁止跳过 DRC。GitHub Pages 的成功与 FPGA bitstream 无关。
- CI：`bash scripts/run_rtl_tests.sh`（17 组），`python3 -m unittest discover -s tests -v`，`python3 scripts/check_quartus_example.py`，`python3 scripts/check_vivado_example.py`，`python3 scripts/check_open_source_example.py`，Playwright 首页与 01—28。

## 第四批工程工具、IP、AXI 与软核边界
- Quartus：QSF/QPF 属于工程输入，SDC 是独立时序模型；不能用一份通用时钟周期替代板级 I/O 延迟和 pin/IOSTANDARD。项目脚本必须要求真实 `FPGA_FAMILY` 与完整 `FPGA_DEVICE`，不允许猜测开发板型号。
- Questa：当前 Altera 仿真器按官方版本称为 Questa-Altera FPGA Edition；Starter Edition 免费但需要 no-cost license。CI 不安装受许可模拟器时，只能报告 Icarus 结果，不得声称 Questa 通过。
- IP：保留可重建的 IP 配置、接口定义、VLNV/版本和依赖；生成的 output products/cache 与源配置分开。Platform Designer 的 Avalon 与 AXI 连接需遵循接口时钟、复位、数据宽度和协议桥约束。
- AXI4-Lite：`axi4lite_regs.v` 仅为 32-bit、单 outstanding 教学 subordinate；AW/W 独立缓存，B/R response 在 READY 前保持稳定，WSTRB 做 byte-enable。不可宣传为完整 AXI4 burst / 多 ID / DMA / CDC 互连。
- Softcore：本章以 MicroBlaze V（RISC-V）为例，必须与 classic MicroBlaze 区分。地址宏来自生成的 `xparameters.h`，固件 ABI 与 RV32/RV64 配置一致；不能把示例 base address 当成板级固定地址。
- 工程可复现：提交 QSF/SDC/XPR/XCI/QSYS 等真实输入（按实际 flow 选择），忽略可再生数据库与缓存；build manifest 记录 SHA-256、part、工具版本和 Git revision，但不自动保证 bitstream 字节级重现。
- 本批不虚构 Quartus Fitter、TimeQuest、Questa、Vivado bitstream、LUT/FF/Fmax 或板级测试结果。GitHub Actions 的 RTL/静态/浏览器通过只能证明对应检查范围。
- CI：17 组 Icarus RTL 回归、`python3 -m unittest discover -s tests -v`、Quartus/Vivado 静态脚本检查、首页及 01—28 Playwright。


## 第五批 RISC-V、SerDes、调试、开源工具与时序功耗边界
- RISC-V：区分 ISA 与微架构。RV32I 基础格式 R/I/S/U 与 B/J 立即数变体不可混淆；所有立即数的符号位来自 inst[31]。本仓库只提供立即数生成与 hazard unit，不得称为完整 CPU、ISA 合规核或已运行 C 程序。
- Hazard：Forwarding 优先级 EX/MEM > MEM/WB，排除 rd=x0；load-use stall 只检查 ID 指令实际使用的 rs1/rs2。本模块未实现分支 flush、异常、cache、总线和完整流水线。
- SerDes：区分 NRZ raw bit rate、GT/s、line coding efficiency 与 protocol payload。PCIe Gen5 32 GT/s 是 NRZ + 128b/130b；PAM4 / FLIT / FEC 属于 PCIe 6.0。AMD GTH/GTY line rate 由具体 part/speed grade 限定，不可跨家族泛化。链路预算脚本只覆盖 NRZ 与简单编码比例。
- MIPI：D-PHY 电气层与 CSI-2/DSI 协议层分开；不能把 D-PHY 简化成通用 LVDS 或无条件电阻网络。无目标器件/原理图时不声明 MIPI PHY 可实现。
- 调试：ILA/SignalTap 按目标时钟域采样；VIO/JTAG-to-AXI 是慢速 JTAG 控制/事务，不是确定性高速激励。probe width × depth 仅是原始样本位数估算，不是实际 BRAM/LUT 资源报告。
- 开源工具：Yosys、nextpnr、Verilator、packer 和 programmer 职责分离。nextpnr backend 支持列表需标记 alpha/experimental；Nexus 属 alpha，NG-Ultra bitstream 需专有 Impulse；不能声称开源工具对所有器件、PLL、SerDes、DDR 或 IP 都完整支持。
- iCEstick example 使用 upstream nextpnr iCE40 blinky 的板级 pin mapping。其他开发板必须核对原理图、封装和引脚；CI 只做静态契约检查，不声称生成 bitstream、下载或上板运行。
- Timing/power：setup slack 教学公式不替代 min/max STA、clock latency、OCV、I/O delay 或 CDC 审计；动态功耗公式不替代实现网表、活动文件、器件电压与热条件驱动的 power report。禁止虚构 WNS、TNS、Fmax、功耗比例或资源占用。
- CI：17 组 Icarus RTL 回归；`python3 -m unittest discover -s tests -v`；静态 HTML/SVG、Quartus/Vivado/Open-source 示例契约；Playwright 首页 + 01—28。


## 第六批工程与全站完成定义（26—28）
- HLS：声明 C-Sim、C synthesis、RTL Co-sim、implement/STA 的不同证据层级。PIPELINE II=1 仅是目标；资源端口、依赖与器件实现决定 achieved II。C++ `fir4` 每次调用一笔样本，reset invocation 不等于已证明的硬件 reset pin；没有 Vitis HLS 测试时不得写已合成、已通过 II 或已测 Fmax。
- AI RTL：不要把模型 benchmark 通过率宣传为工程正确率；需求必须给出模块、位宽、时钟、复位、握手时刻、输出稳定性和验收方法。至少有独立 scoreboard 验证 backpressure、full/empty、同拍读写和 drain；模拟测试不是形式证明。不得向未经批准的外部服务泄露敏感 IP、数据或配置。
- Ready/Valid slice：单 entry、单时钟、同步 active-low reset、无组合数据 bypass，但存在 m_ready 到 s_ready 的组合依赖；它不是完整异步 FIFO，也不是完全断开 READY 路径的 skid buffer。
- AXI4-Stream Video：SOF = TUSER[0] 的帧首像素，TLAST = 每行 EOL。只有 TVALID && TREADY 才传输像素；所有 data / sideband 在停顿时必须稳定。不能把普通 DVP 直接当作带 READY 的 AXI 流。
- 图像系统：本仓库仅实现 RGB888 到加权 gray8 / Binary8 的单像素流水线（带 SOF/EOL），testbench 只有合成 7x4 帧。3x3 Sobel、camera PHY、DDR DMA、CDC、frame ownership、显示 timing / PHY 均为详细设计指南而非已完成硬件。
- DDR 裸像素预算公式是吞吐下界；必须注明像素格式、stride、帧数、fps、读写方向及总线开销。不得宣称实际 DDR 带宽达到工具输出的裸像素值。
- 回归：17 组 Icarus、Python unittest、FIR4 portable C++ test、HTML/SVG/link、工具链静态契约和 Playwright 首页 + 01—28 在四种宽度；新章节原生 details 和 MathML 可访问性须验收。GitHub Pages 成功不是板级签核。


## 2026-11-23 第二轮复审补充（26—28 与质量门禁）
- Ready/Valid testbench 的源端也必须遵守握手契约：若 `s_valid && !s_ready`，下一拍必须保持 VALID 与 DATA，直到握手。drain 阶段不得直接撤销尚未接受的 pending 项；测试必须覆盖 full+stall、同拍 dequeue/enqueue、source stability、output stability、最终 drain。
- 视频流 testbench 必须同时检查输入端和输出端的 DATA/SOF/EOL 停顿稳定性，并统计输出 SOF 数等于帧数、EOL 数等于帧数×行数。
- 帧缓存预算同时报告 `active_pixel_stride_write_bytes_per_second` 与 stride-based `stride_write_bytes_per_second`；帧存储按 stride×height 计算，DDR/AXI 传输预算按 fps×height×stride 计算。不可将有效像素字节速率冒充 padded-stride DMA 速率。
- MathML：所有公式必须有可访问名称；`mfrac` 恰好两个子元素；矩阵用 `mtable/mtr/mtd`；公式区必须 keyboard focusable，实际溢出时必须能用方向键横向滚动。浏览器检查要比较分子/分母几何位置，不可只检查 DOM 存在。
- HTML 静态门禁：检查跨页面 fragment、figure media + nonempty figcaption、SVG title/desc/aria-labelledby、MathML 结构与 evidence schema v2。证据状态只允许 `verified`、`derived`、`illustrative`、`unverified`；未复核的历史 claim 应标 unverified，不可自造 supported。
- 官方来源复核日期 2026-11-23：UG1399 2026.2、UG1387 2026.1、PG278 3.1、PG043 5.0、PG044 4.0、Arm AMBA AXI、NVIDIA VerilogEval、RTLLM、Yosys 0.70、NIST AI 600-1。若产品文档 URL 有版本化/非版本化 canonical 差异，以可打开的官方页面 URL 为准。
- Chapter 28 bandwidth figure 明确假设无行填充 stride=5760；实际 stride 必须通过 `--stride-bytes` 输入并重新计算。任何 1080p 带宽数字必须注明 RGB888、fps、stride、读/写方向。
