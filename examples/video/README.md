# Video thresholding IP — functional teaching slice only

The RTL file examples/rtl/rgb_threshold_stream.v converts each RGB888 pixel
to 8-bit grayscale using (77R+150G+29B+128)>>8 and thresholds it to 0 or 255.
It is a one-stage registered AXI4-Stream Video-style ready/valid processor.
Start-of-frame TUSER and end-of-line TLAST travel with each accepted pixel.
Under backpressure, output VALID, DATA, SOF and EOL remain stable.

Run 3 synthetic 7x4 frames with randomized sink stalls:

    bash scripts/run_rtl_tests.sh

Uncompressed 1920x1080 RGB888 frame storage and traffic estimate:

    python3 scripts/frame_budget.py --width 1920 --height 1080 \
      --bytes-per-pixel 3 --fps 60 --buffers 2

The RTL does NOT include DVP/MIPI camera capture, debayering, line buffers,
Sobel, DDR/AXI-MM DMA, CDC, frame synchronization or display timing generation.
DDR bandwidth excludes burst overhead and arbitration, and actual display
timing additionally includes blanking intervals.

Primary sources:
https://docs.amd.com/r/en-US/2026.1/pg278-v-frmbuf/Core-Behavior-with-EOL-and-SOF-Signals
https://docs.amd.com/r/en-US/2026.1/pg278-v-frmbuf/System-Considerations
