# 第六批 26–28 深度技术复审与实验边界

| 章节 | 原始文章常见缺陷 | 本轮独立内容 | 可运行范围 | 未执行或不宣称的内容 |
|---|---|---|---|---|
| 26 HLS | 把 pragma 等同于 II=1；不区分 C-Sim/Co-Sim；忽略内存端口与状态依赖 | 延迟与 II、loop unroll、array partition、dataflow、FIR 固定点位宽和验证分层 | 4-tap FIR portable C++ reference + 独立 golden + 极值/脉冲/随机数据 | 未运行 AMD Vitis HLS、Co-Sim、实现报告、真实 II/Fmax/area |
| 27 AI RTL | 无法评估的行业预测/模型胜率；由同一模型编写唯一自测；忽略 READY 背压 | 规格合同、单 entry elastic buffer、scoreboard、VerilogEval/RTLLM benchmark 范围与工程 gate | 16-bit 同域 Ready/Valid 弹性缓存 + 定向/随机顺序测试 | 不是形式证明、异步 FIFO、完全打断 READY、PPA 签核或特定模型生成宣称 |
| 28 视频系统 | 把 TLAST 当作 EOF；未经验证直接声称 MIPI/DDR/VGA 形成完整系统；凭经验断言带宽 | 摄像头到显示的 clock/PHY/DMA 边界、AXI4 Video SOF/EOL、gray/threshold、DDR 双缓冲所有权、像素时钟算式 | RGB888 → Gray8 → Binary8 one-beat stream；3 帧 7x4 测试与 frame_budget.py | 未实现/实测 camera PHY、DDR DMA、Sobel、CDC、显示 timing、bitstream 或板卡 |

## 每章视觉证据
- 26：HLS flow / II timeline / memory-port banking / FIR datapath。
- 27：AI evidence pipeline / elastic buffer states / backpressure timing / acceptance matrix。
- 28：system pipeline / SOF-EOL pixels / pixel transform / double buffer ownership / frame bandwidth。
总计 13 个自绘 SVG，含 title/desc、alt、图注，无外链 JS 依赖。

## 验收
- 17 组 Icarus RTL 回归（含 ready_valid_slice 与 rgb_threshold_stream）。
- Python unittest（含 frame_budget）以及可移植 FIR4 C++ 参考测试。
- HTML/链接/SVG XML 与证据账本；Playwright 29 页 × 4 宽度、8 个 native details、MathML 可访问性和打印样本。
- GitHub CI 成功仅表示对应检查范围通过；绝不等同于生成/下载 FPGA bitstream 或完成真实器件时序签核。
