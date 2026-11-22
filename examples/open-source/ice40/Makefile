# Requires yosys, nextpnr-ice40, icepack; board programming is a separate explicit step.
TOP := blink
BUILD := build
RTL := blink.v
PCF := blink.pcf

.PHONY: all clean flash
all: $(BUILD)/$(TOP).bin

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/$(TOP).json: $(RTL) | $(BUILD)
	yosys -p "read_verilog $(RTL); synth_ice40 -top $(TOP) -json $@"

$(BUILD)/$(TOP).asc: $(BUILD)/$(TOP).json $(PCF)
	nextpnr-ice40 --hx1k --package tq144 --json $< --pcf $(PCF) --asc $@ --freq 12

$(BUILD)/$(TOP).bin: $(BUILD)/$(TOP).asc
	icepack $< $@

flash: $(BUILD)/$(TOP).bin
	@test "$(CONFIRM_FLASH)" = "YES" || (echo "Set CONFIRM_FLASH=YES after checking the connected iCEstick."; exit 2)
	iceprog $<

clean:
	rm -rf $(BUILD)
