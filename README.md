# 🔧 FPGA/Verilog 嵌入式开发 · 从入门到精通

> 📘 28章 实战体系

一套完整的 **FPGA/Verilog 嵌入式开发 · 从入门到精通** 全中文实战课程体系，共 **28 章**。本课程以 HTML 可视化的形式呈现，从基础原理到工程实践循序渐进，适合系统性学习与复习。

## 🚀 快速开始

无需安装任何依赖，直接用浏览器打开 `index.html` 即可在线阅读全部章节：

```bash
open index.html   # macOS
# 或在浏览器中直接打开 index.html
```

## 📖 章节目录

| # | 章节 | 核心主题 |
|---|------|----------|
| 01 | 课程导论与FPGA发展史 | FPGA起源与演进、PAL→CPLD→FPGA、厂商格局（Xilinx→AMD、Altera→Intel）、FPGA vs MCU/GPU/ASIC |
| 02 | 数字电路基础回顾 | 组合逻辑与真值表、时序逻辑与触发器、建立/保持时间、同步电路设计原则 |
| 03 | Verilog HDL语法精要（上） | 模块结构与端口、wire vs reg、assign连续赋值、运算符体系 |
| 04 | Verilog HDL语法精要（下） | always块两张面孔、阻塞赋值 vs 非阻塞赋值、if-else/case综合行为、parameter与localparam |
| 05 | 组合逻辑设计实战 | 多路选择器多种写法、译码器与编码器、ALU设计、竞争与冒险 |
| 06 | 时序逻辑设计实战 | 计数器设计、奇数/偶数分频器、移位寄存器与LFSR、按键消抖与边沿检测 |
| 07 | 有限状态机（FSM）设计 | Moore vs Mealy、三段式FSM写法、状态编码策略、序列检测/售货机/UART框架 |
| 08 | Testbench编写与仿真验证 | Testbench基本结构、激励生成技术、结果检查与Golden Model、仿真工具生态对比 |
| 09 | 常用通信接口实现（一）：UART与SPI | UART协议与16x过采样、UART收发器FSM实现、SPI四种模式CPOL/CPHA、SPI主机控制器 |
| 10 | 常用通信接口实现（二）：I2C | I2C开漏输出物理层、主机多字节读写状态机、从机地址匹配与寄存器模型、总线死锁恢复 |
| 11 | 存储器设计与Block RAM | 分布式RAM vs Block RAM、单/双端口RAM设计、同步FIFO与异步FIFO、BRAM原语例化 |
| 12 | 流水线设计技术 | 流水线原理与fmax提升、深度选择与寄存器切割、流水线冒险与解决、四级流水线乘法器实战 |
| 13 | 跨时钟域（CDC）处理 | 亚稳态物理本质与MTBF、两级同步器（2-FF）、异步FIFO格雷码指针、CDC设计检查清单 |
| 14 | 时序约束与分析基础 | Setup/Hold Slack公式、create_clock与时钟组、I/O延迟约束、时序违例诊断与修复 |
| 15 | Vivado工程实战全流程 | 工程创建→综合→布线→比特流、ILA片上逻辑分析仪、XDC约束文件编写、2026.1 Linux取消免费版影响 |
| 16 | Quartus Prime与ModelSim | Quartus工程流程、SignalTap II逻辑分析仪、ModelSim仿真集成、Vivado vs Quartus全面对比 |
| 17 | 常用IP核集成与应用 | PLL/MMCM时钟管理、FIFO Generator配置、Block Memory Generator、Block Design集成方法 |
| 18 | 工程目录规范与版本管理 | 七目录工程结构、Git管理策略与.gitignore、团队协作规范、Tcl脚本可复现构建 |
| 19 | AXI4总线协议深度解析 | AMBA协议族全景、五个独立通道、VALID/READY握手机制、AXI4-Lite从设备实现 |
| 20 | 软核处理器集成 | MicroBlaze/Nios II体系、软核+RTL协处理架构、Vitis软件开发流程、软核 vs 硬核对比 |
| 21 | RISC-V处理器FPGA实现 | RV32I指令集与格式、五级流水线数据通路、流水线冒险与前推、FPGA上运行RISC-V程序 |
| 22 | 高速串行接口设计 | SerDes与8b/10b编码、FPGA高速收发器层级、PCIe Gen3/4/5概述、MIPI DSI/CSI FPGA实现 |
| 23 | 硬件调试方法论 | 五层调试金字塔、状态机可视化调试、ILA触发条件与波形分析、VIO虚拟I/O注入激励 |
| 24 | 开源工具链实战 | Yosys综合器与pass体系、nextpnr布局布线、开源FPGA开发板推荐、Verilator高速仿真与Lint |
| 25 | 时序收敛与功耗优化 | 时序收敛系统方法六步法、物理优化与Pblock、功耗估算与时钟门控、违例根因分析心理模型 |
| 26 | 高层次综合（HLS）入门 | Vitis HLS工作流程、PIPELINE/UNROLL/DATAFLOW、HLS vs RTL适用场景共识、FIR滤波器C++与Verilog对照 |
| 27 | AI时代的FPGA开发 | LLM生成Verilog实用技巧、AI辅助工具链全景、自然语言→比特流路径、FPGA工程师角色转型 |
| 28 | 综合项目：FPGA图像采集与处理系统 | OV5640摄像头DVP采集、DDR3帧缓存MIG IP、Sobel边缘检测流水线、VGA显示时序与系统集成 |

## 📂 项目结构

```text
fpga-verilog-tutorial/
├── index.html      # 课程主入口（在线阅读全部章节）
├── 01.html ~ 28.html   # 各章节正文
├── courses.json    # 课程元数据（标题/章节/主题）
└── theme.css       # 统一主题样式
```

## ✨ 课程特色

- **全中文实战体系**：面向中文读者，由浅入深，覆盖原理与工程实践
- **28 章完整内容**：系统化章节编排，形成完整知识闭环
- **可视化呈现**：HTML 图文并茂，适合快速浏览与重点回顾
- **即开即用**：无需构建、无需服务器，纯静态页面随开随看

---
*本课程由 `fpga-verilog-tutorial/` 项目维护。*