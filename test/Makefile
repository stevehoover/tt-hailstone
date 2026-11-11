# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
FST ?= -fst # Use more efficient FST format
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = project.sv  # Generated from project.tlv (make verilog) and committed.

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

else

# Gate level simulation:
SIM_BUILD				= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DSIM
# Cell models for the PDK in $(PDK) (set by the gl_test action from the build; see info.yaml), as in each
# PDK's Tiny Tapeout template (see UPSTREAM.md).
PDK ?= sky130A
ifeq ($(PDK),sky130A)
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
else ifeq ($(PDK),gf180mcuD)
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/gf180mcu_fd_sc_mcu7t5v0.v
else
# IHP (ihp-sg13cmos5l or ihp-sg13g2), e.g. sg13cmos5l_stdcell.v
PDK_CELL_PREFIX = $(patsubst ihp-%,%,$(PDK))
PDK_LIBS_REF = $(PDK_ROOT)/$(PDK)/libs.ref
VERILOG_SOURCES += $(PDK_LIBS_REF)/$(PDK_CELL_PREFIX)_io/verilog/$(PDK_CELL_PREFIX)_io.v
# Newer PDK versions ship the UDP (user-defined primitive) models in a separate file
VERILOG_SOURCES += $(wildcard $(PDK_LIBS_REF)/$(PDK_CELL_PREFIX)_stdcell/verilog/$(PDK_CELL_PREFIX)_udp.v)
VERILOG_SOURCES += $(PDK_LIBS_REF)/$(PDK_CELL_PREFIX)_stdcell/verilog/$(PDK_CELL_PREFIX)_stdcell.v
endif

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Allow sharing configuration between design and testbench via `include`:
COMPILE_ARGS 		+= -I$(SRC_DIR)

# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

# List test modules to run, separated by commas and without the .py suffix:
COCOTB_TEST_MODULES = test

# include cocotb's make rules to take care of the simulator setup (not needed to just build Verilog)
ifneq ($(MAKECMDGOALS),verilog)
include $(shell cocotb-config --makefiles)/Makefile.sim
endif

# TL-Verilog: generate src/*.sv from src/*.tlv with SandPiper-SaaS. Commit the result.
$(SRC_DIR)/%.sv: $(SRC_DIR)/%.tlv
	@command -v sandpiper-saas > /dev/null || (echo "Install SandPiper-SaaS: pipx install sandpiper-saas" && exit 1)
	cd $(SRC_DIR) && sandpiper-saas -i '$(<F)' -o '$(@F)' --outdir . --sv_url_inc --inlineGen --noline --clkAlways --bestsv --iArgs

.PHONY: verilog
verilog: $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
