# 第三批 11–15 技术复审记录

| 章节 | 原版问题 | 替代的严谨叙述 | 可执行证据 |
|---|---|---|---|
| 11 | 将双时钟同址碰撞简单归因于 WRITE_FIRST，建议切换 READ_FIRST 解决花屏 | 区分单端口同步读旧值和双端口跨时钟物理冲突；单纯切换模式并不能保证安全 | 单端口 READ_FIRST + 同步 FIFO testbench；AMD UG901 / UG573 |
| 12 | 预设 Artix-7 16×16 乘法器可达 380MHz 并编造 LUT/FF 数值 | 频率和资源依赖实际布线与器件；本章不给目标 Fmax 数值 | 三寄存级、18-bit 宽度、valid/CE 对齐测试 |
| 13 | 从抽象 MTBF 公式推断特定 FPGA 的固定故障率，夸大 Gray FIFO 自动安全 | MTBF 依赖实际器件和 PVT；Gray CDC 仍需偏斜/路径约束 | 单事件 toggle handshake；AMD UG949 CDC |
| 14 | 没有一致符号约定地宣称时钟余量百分比；含可误用的 false_path / XDC | 单时钟算术示例明确 skew 符号；IO min/max 从外部数据手册推导，禁止伪造约束 | STA Python 单元测试，静态接口 XDC |
| 15 | 断言 2026.1 Linux 免费 Vivado 已取消 | AMD BASIC 免费且表格列出 Windows/Linux；实际覆盖取决于 part 和层级 | Guarded Tcl，静态模板检查、官方许可页 |

## 验收界限
- GitHub Actions 只安装 Icarus/Playwright/Python；不下载或运行 Vivado。
- 设计图不是网表截图；文章没有声称已经做过 FPGA 上板或获取硬件资源报告。
- 不因静态检查和协议模块的仿真通过就对异步 FIFO、STA 或生产部署出具验收结论。
