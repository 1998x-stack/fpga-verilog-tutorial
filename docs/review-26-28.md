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


## 第二轮复审：缺陷、修复与重新验收范围（2026-11-23）

### 已修复的问题
1. **Ready/Valid 输入源违反契约：** 原 testbench 在随机循环结束后无条件将 `s_valid` 拉低，可能丢弃尚未被接受的最后一笔事务。修复为 drain 时继续保持 pending VALID/DATA，直到握手；加入 source-stability 断言，并增加定向 full+stall → 同拍 dequeue/enqueue 测试和 coverage counter。
2. **视频源端验证不完整：** 新增 source DATA/TUSER/TLAST 停顿稳定断言，并显式统计输出 SOF 与 EOL 数量，必须分别等于 3 帧与 12 行。
3. **DDR/帧缓存 stride 预算低估：** 旧工具仅按活动像素字节计算写入量，即使设置了 stride padding 也不会增加传输预算。AMD PG278 System Considerations 明确给出 fps × height × stride。现将 active-pixel rate 与 stride-based DMA rate 分开输出；测试覆盖 15-byte 活动行、16-byte stride 的差异。
4. **公式语义不足：** 将 FIR4 方程、Sobel 两个 3×3 卷积核、活动像素/stride 带宽关系、显示器总周期/像素时钟改为带可访问名称的 MathML；浏览器检查实际 fraction 几何、矩阵行列和键盘滚动。
5. **示例代码与 RTL 不一致：** Chapter 26 的 FIR 讲解代码补齐 signed 32-bit 显式扩展；Chapter 27 的单级 buffer 复位写法改为 Verilog-2001 可移植的参数化复制，不再使用 SystemVerilog unsized unbased literal。
6. **外部引用修正：** PG278 Overview 使用可访问的 canonical URL（不再使用无效的版本化路径）；新增 UG1399 Co-Simulation 两笔事务计算 II 的官方说明链接；NIST AI 600-1 改为直接链接；补充 2026 synthesis-in-the-loop 论文原始 arXiv 链接。

### 证据账本与质量门禁
- `data/evidence.json` 升级为 schema v2，所有记录具备 id、kind、source_url、locator、status 和 notes。
- Chapters 26–28 的 17 条来源/派生记录标为 verified/derived；01–25 的 53 条旧记录保留 claim/source，但迁移为 unverified，直到下一轮逐条复查。避免把历史状态误称为本轮重新验证。
- `scripts/check_site.py` 新增跨页面锚点、figure caption、MathML accessible name、mfrac 子元素数量、SVG id/aria-labelledby 与 evidence schema 检查。
- `scripts/browser_check.py` 新增图注、离线资源、MathML fraction 真实布局、键盘滚动、MathML namespace 和 SVG 内嵌 MathML 检查。

### 本轮重新核对的官方来源
- AMD UG1399：Vitis HLS 2026.2（Pipeline、Array Accesses and Performance、Unroll、Dataflow、Co-simulation、Block-Level Control Protocols）。
- AMD UG1387：Vitis HLS Debug and Verification Considerations 2026.1。
- AMD PG278：Video Frame Buffer Read/Write 3.1；SOF/TUSER、EOL/TLAST、System Considerations 的 stride 带宽公式。
- AMD PG043 v5.0 / PG044 v4.0：Video In 与 Video Out AXI4-Stream 接口。
- Arm AMBA AXI Protocol Specification：VALID/READY 握手及 payload 保持。
- NVIDIA VerilogEval（156 个 HDLBits-derived tasks）、RTLLM 项目、2026 arXiv 2603.11287、Yosys 0.70 symbolic model checking、NIST AI 600-1。


**补充 HLS 复审：** UG1399 2026.2 的 *Limitations of Pipelining with Static Variables* 明确说明 static state 的读写依赖可能阻止达到请求 II，示例可导致最小 II=2。FIR4 保留 static delay history，因此将 II=1 明确标为优化目标；不得预期、宣称或记录 achieved II，直到 Vitis HLS scheduling report / RTL Co-Sim 提供证据。