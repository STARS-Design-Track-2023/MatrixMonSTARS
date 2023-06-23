###########################################################################################
# STARS 2023 General Makefile
# 
# Set tab spacing to 2 spaces per tab for best viewing results
###########################################################################################

export PATH            := /home/shay/a/ece270/bin:$(PATH)
export LD_LIBRARY_PATH := /home/shay/a/ece270/lib:$(LD_LIBRARY_PATH)

##############################################################################
# VARIABLES
##############################################################################

# Source

# Specify the name of the top level file (do not include the source folder in the name)
# NOTE: YOU WILL NEED TO SET THIS VARIABLE'S VALUE WHEN WORKING WITH HEIRARCHICAL DESIGNS
TOP_FILE         := 

# List internal component/block files here (separate the filenames with spaces)
# NOTE: YOU WILL NEED TO SET THIS VARIABLE'S VALUE WHEN WORKING WITH HEIRARCHICAL DESIGNS
COMPONENT_FILES  := 

# Specify the filepath of the test bench you want to use (ie. tb_top_level.sv)
# (do not include the source folder in the name)
TB               := 

# Get the top level design and test_bench module names
TB_MODULE		 := $(notdir $(basename $(TB)))
TOP_MODULE	     := $(notdir $(basename $(TOP_FILE)))

# Simulation
WF               ?= 0

# Directries where the source and mapped code is located
SRC              := source
MAP              := mapped

# Location of executables
BUILD            := sim_build

# Simulation Targets
SIM_SOURCE       := sim_source
SIM_MAPPED       := sim_mapped

DUMP             := dump

# Compiler
VC               := iverilog
# Flags currently described specify the 2012 IEEE verilog standard, require compiler
# to look into the specify blocks in a cell lib, choose the max timings form the 
# parameters and print out the compiler verbose.
CFLAGS           := -g2012 -v

# Design Compiler
DC               := yosys

# FPGA project vars and filenames
PROJ	         := ice40
PINMAP 	         := $(PROJ)/pinmap.pcf
ICE   	         := $(PROJ)/ice40hx8k.sv
UART	         := $(addprefix $(PROJ)/uart/, uart.v uart_tx.v uart_rx.v)
FILES            := $(ICE) $(SRC)/top.sv $(addprefix $(SRC)/, $(TOP_FILE) $(COMPONENT_FILES)) $(UART)
FPGA_BUILD       := ./$(PROJ)/build

# FPGA specific configuration
DEVICE           := 8k
TIMEDEV          := hx8k
FOOTPRINT        := ct256

# Cell libraries
PDK              := $(PDK_ROOT)
LIBERTY          := $(PDK)/lib/sky130_fd_sc_hd__tt_100C_1v80.lib
VERILOG          := $(PDK)/verilog/primitives.v $(PDK)/verilog/sky130_fd_sc_hd.v

# binary names
NEXTPNR          :=nextpnr-ice40
SHELL            :=bash

##############################################################################
# RULES
##############################################################################


##############################################################################
# Administrative Targets
##############################################################################

###########################################################################################
# Make the default target (the one called when no specific one is invoked) to
# output the proper usage of this makefile
###########################################################################################
help:
	@echo "----------------------------------------------------------------"
	@echo "|                       Makefile Targets                       |"
	@echo "----------------------------------------------------------------"
	@echo "Administrative targets:"
	@echo "  all           - compiles the source version of a full"
	@echo "                  design including its top level test bench"
	@echo "  setup         - Setups the directory for work"
	@echo "  help          - makefile targets explanation"
	@echo "  clean         - removes the temporary files"
	@echo "  print_vars    - prints the contents of the variables"
	@echo
	@echo "Compilation targets:"
	@echo "  source       - compiles the source version of a full"
	@echo "                 design including its top level test bench"
	@echo "  mapped       - compiles and synthesizes the mapped version"
	@echo "                 of a full design including its top level" 
	@echo "                 test bench"
	@echo
	@echo "Simulation targets:"
	@echo "  sim_source   - compiles and simulates the source version"
	@echo "                 of a full design including its top level"
	@echo "                 test bench"
	@echo "  sim_mapped   - compiles and simulates the mapped version"
	@echo "                 of a full design including its top level"
	@echo "                 test bench"
	@echo 
	@echo "Miscellaneous targets:"
	@echo "  lint         - checks syntax for source files with the"
	@echo "                 Verilator linter"
	@echo "  verify       - view traces with gtkwave. If you have a wave"
	@echo "                 foramt file saved run 'make verify WF=filename'"
	@echo "                 do not give the file extension .gtkw. Wave"
	@echo "                 format file must be saved in same directory as"
	@echo "                 the makefile."
	@echo "  rtl          - view the rtl schematic"
	@echo
	@echo "FPGA targets:"
	@echo "  ice          - synthesizes the source files along with the"
	@echo "                 ice40 files to make and netlist and then"
	@echo "                 place and route to program ice40 FPGA as per"
	@echo "                 the given design."
	@echo "----------------------------------------------------------------"

all: $(SIM_SOURCE)

# A target that sets up the working directory structure
setup:
	@mkdir -p ./docs
	@mkdir -p ./$(MAP)
	@mkdir -p ./$(BUILD)
	@mkdir -p ./$(SRC)

# Removes all non essential files that were made during the building process.
clean:
	@echo "Removing temporary files, build files and log files"
	@rm -rf $(BUILD)/*
	@rm -rf $(MAP)/*
	@rm -f *.log
	@rm -f *.vcd
	@rm -rf $(PROJ)/build
	@rm -f xt
	@echo -e "Done\n\n"

print_vars:
	@echo -e "Component Files: \n $(foreach file, $(COMPONENT_FILES), $(file)\n)"
	@echo "Top level File: $(TOP_FILE)"
	@echo "Testbench: $(TB)"
	@echo "Top level module: $(TOP_MODULE)"
	@echo "Testbench module: $(TB_MODULE)"
	@echo "Gate Library: '$(PDK)'"
	@echo "Source work library: '$(SRC)'"
	@echo "Mapped work library: '$(MAP)'"


##############################################################################
# Compilation Targets
##############################################################################

# Define a pattern rule to automatically compile updated source files for a design
$(SRC): $(addprefix $(SRC)/, $(TOP_FILE) $(COMPONENT_FILES) $(TB))
	@echo "----------------------------------------------------------------"
	@echo "Creating executable for source compilation ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@mkdir -p ./$(BUILD)
	@$(VC) $(CFLAGS) -o $(BUILD)/$(SIM_SOURCE).vvp $^
	@echo -e "\n\n"
	@echo -e "Compilation complete\n\n"

# Define a pattern rule to automatically compile mapped design files for a full mapped design
$(MAP): $(addprefix $(SRC)/, $(TOP_FILE) $(COMPONENT_FILES) $(TB))
	@echo "----------------------------------------------------------------"
	@echo "Synthesizing and Compiling with sky130_fd_sc_hd ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@mkdir -p ./$(MAP)
	@mkdir -p ./$(BUILD)
	@touch -c $(TOP).log
	@$(DC) -d -p 'read_verilog -sv -noblackbox $(addprefix $(SRC)/, $(TOP_FILE) $(COMPONENT_FILES)); synth -top $(TOP_MODULE); dfflibmap -liberty $(LIBERTY); abc -liberty $(LIBERTY); clean; write_verilog -noattr -noexpr -nohex -nodec -defparam $@/$(TOP_MODULE).v' > $(TOP_MODULE).log
	@echo "Synthesis complete .....\n\n"
	@$(VC) $(CFLAGS) -o $(BUILD)/$(SIM_MAPPED).vvp -DFUNCTIONAL -DUNIT_DELAY=#1 $@/$(TOP_MODULE).v $(SRC)/$(TB) $(VERILOG)
	@echo -e "\n\n"
	@echo -e "Compilation complete\n\n"


##############################################################################
# Simulation Targets
##############################################################################

# This rule defines how to simulate the source form of the full design
$(SIM_SOURCE): $(SRC)
	@echo "----------------------------------------------------------------"
	@echo "Simulating source ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@vvp -lxt -s $(BUILD)/$@.vvp
	@echo -e "\n\n"

# This rule defines how to simulate the mapped form of the full design
$(SIM_MAPPED): $(MAP)
	@echo "----------------------------------------------------------------"
	@echo "Simulating mapped ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@vvp -lxt -s $(BUILD)/$@.vvp
	@echo -e "\n\n"


##############################################################################
# FPGA Targets
##############################################################################

# this target checks your code and synthesizes it into a netlist
$(FPGA_BUILD)/$(PROJ).json : $(ICE) $(addprefix $(SRC)/, $(COMPONENT_FILES) $(TOP_FILE)) $(PINMAP) $(SRC)/top.sv
	@echo "----------------------------------------------------------------"
	@echo "Checking Syntax ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@verilator --lint-only -Werror-WIDTH -Werror-SELRANGE -Werror-COMBDLY -Werror-LATCH -Werror-MULTIDRIVEN $(SRC)/top.sv $(addprefix $(SRC)/, $(COMPONENT_FILES) $(TOP_FILE))
	@mkdir -p $(FPGA_BUILD)
	@echo "----------------------------------------------------------------"
	@echo "Synthesizing to ice40 ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@$(DC) -p "read_verilog -sv -noblackbox $(FILES); synth_ice40 -top ice40hx8k -json $(FPGA_BUILD)/$(PROJ).json" > $(PROJ).log
	@echo -e "\n\n"
	@echo -e "Synthesis Complete \n\n"
	
# Place and route using nextpnr
$(FPGA_BUILD)/$(PROJ).asc : $(FPGA_BUILD)/$(PROJ).json
	@echo "----------------------------------------------------------------"
	@echo "Mapping to ice40 ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@$(NEXTPNR) --hx8k --package ct256 --pcf $(PINMAP) --asc $(FPGA_BUILD)/$(PROJ).asc --json $(FPGA_BUILD)/$(PROJ).json 2> >(sed -e 's/^.* 0 errors$$//' -e '/^Info:/d' -e '/^[ ]*$$/d' 1>&2) >> $(PROJ).log
	@echo -e "\n\n"
	@echo -e "Place and Route Complete \n\n" 

# Convert to bitstream using IcePack
$(FPGA_BUILD)/$(PROJ).bin : $(FPGA_BUILD)/$(PROJ).asc
	@icepack $(FPGA_BUILD)/$(PROJ).asc $(FPGA_BUILD)/$(PROJ).bin >> $(PROJ).log
	@echo -e "\n\n"
	@echo -e "Converted to Bitstream for FPGA \n\n" 
	
# synthesize and flash the FPGA
ice : $(FPGA_BUILD)/$(PROJ).bin
	@echo "----------------------------------------------------------------"
	@echo "Flashing onto FPGA ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@iceprog -S $(FPGA_BUILD)/$(PROJ).bin


##############################################################################
# Miscellaneous Targets
##############################################################################

# Define a pattern rule to lint source code with verilator
lint: $(addprefix $(SRC)/, $(TOP_FILE) $(COMPONENT_FILES) $(TB))
	@echo "----------------------------------------------------------------"
	@echo "Checking Syntax ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@verilator --lint-only  -Wno-MULTITOP -Wno-TIMESCALEMOD $^
	@echo -e "\n\n"
	@echo -e "Done linting\n\n"

# Rule to look at the waveforms with gtkwave
verify: $(DUMP).vcd
ifeq ($(WF), 0)
	@gtkwave $^
else
	@gtkwave $^ -a $(WF).gtkw
endif

# Rule to look at the gate level schematic of the circuit
rtl: $(addprefix $(SRC)/, $(TOP_FILE) $(COMPONENT_FILES))
	@echo "----------------------------------------------------------------"
	@echo "Generating RTL Schematic ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@$(DC) -d -p 'read_verilog -sv $^; hierarchy -check -top $(TOP_MODULE); proc; opt; fsm; opt; memory; opt; show' > log_mapping.log
	@echo -e "Done creating Schematic \n\n"	

###########################################################################################
# Designate targets that do not correspond directly to files so that they are
# run every time they are called
###########################################################################################
.PHONY: all help clean print_vars
.PHONY: $(SRC) $(MAP)
.PHONY: $(SIM_SOURCE) $(SIM_MAPPED)
.PHONY: lint verify view
.PHONY: ice
###########################################################################################
# Designate targerts that whose runtime warnings/errors may be ignored
###########################################################################################
.IGNORE: lint
