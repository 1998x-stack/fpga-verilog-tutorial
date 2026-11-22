/*
 * MicroBlaze V bare-metal MMIO example for the Chapter 19 register block.
 * The generated xparameters.h macro name depends on the packaged IP instance.
 * Update the macro to match the exact hardware platform before building.
 */
#include <stdint.h>
#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"

#ifndef XPAR_AXI4LITE_REGS_0_S00_AXI_BASEADDR
#error "Replace this macro with the custom IP base-address symbol from generated xparameters.h"
#endif

#define REG_BASE    ((UINTPTR)XPAR_AXI4LITE_REGS_0_S00_AXI_BASEADDR)
#define REG_CTRL    0x00U
#define REG_STATUS  0x04U
#define REG_ID      0x0CU
#define EXPECTED_ID 0x46504741U

static void write_leds(uint32_t value)
{
    Xil_Out32(REG_BASE + REG_CTRL, value & 0x0FU);
}

int main(void)
{
    static const uint32_t pattern[] = {
        0x1U, 0x2U, 0x4U, 0x8U, 0xCU, 0x6U, 0x3U, 0x9U
    };
    uint32_t id;
    uint32_t status;
    unsigned int i;

    id = Xil_In32(REG_BASE + REG_ID);
    if (id != EXPECTED_ID) {
        xil_printf("Custom peripheral ID mismatch: 0x%08x\r\n", (unsigned int)id);
        return 1;
    }

    xil_printf("MicroBlaze V: custom AXI4-Lite peripheral detected\r\n");
    for (;;) {
        for (i = 0; i < sizeof(pattern) / sizeof(pattern[0]); ++i) {
            write_leds(pattern[i]);
            status = Xil_In32(REG_BASE + REG_STATUS);
            xil_printf("LED=0x%01x STATUS=0x%08x\r\n",
                       (unsigned int)pattern[i], (unsigned int)status);
            for (volatile uint32_t delay = 0; delay < 1000000U; ++delay) {
                /* Busy wait for a small bare-metal demonstration. */
            }
        }
    }
}
