# Reproducible FPGA project skeleton

Copy this layout into a real board project and replace every placeholder with values from the board manual and exact tool release.

```text
fpga-project/
├── src/                 # Hand-written RTL
├── sim/                 # Testbenches, simulator scripts, assertions
├── constraints/         # QSF/XDC/SDC and board-specific pin maps
├── ip/                  # IP configuration and custom component source
├── software/            # Firmware, linker scripts, BSP configuration
├── scripts/             # Project generation, build, report, manifest
├── reports/             # Selected, reviewed sign-off reports
├── releases/            # Optional versioned delivery metadata
├── fpga-project.yml     # Tool, target, IP and build manifest
└── .gitignore
```

Track the source project descriptions and IP configuration files needed to recreate the design. Ignore only regenerable databases, caches, temporary simulation data and local logs. Keep final programming files in a versioned release or artifact store when they must be delivered; do not use broad ignore rules to hide source constraints or IP metadata.
