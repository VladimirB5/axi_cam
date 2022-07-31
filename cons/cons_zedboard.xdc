# camera is connected to PMODs JA1 and JB1
# ----------------------------------------------------------------------------
# JA Pmod - Bank 13
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN Y11  [get_ports {SIOC}];  # "JA1"
set_property PACKAGE_PIN AA8  [get_ports {DATA[6]}];  # "JA10"
set_property PACKAGE_PIN AA11 [get_ports {VSYNC}];  # "JA2"
set_property PACKAGE_PIN Y10  [get_ports {PCLK}];  # "JA3"
set_property PACKAGE_PIN AA9  [get_ports {DATA[7]}];  # "JA4"
set_property PACKAGE_PIN AB11 [get_ports {SIOD}];  # "JA7"
set_property PACKAGE_PIN AB10 [get_ports {HREF}];  # "JA8"
set_property PACKAGE_PIN AB9  [get_ports {XCLK}];  # "JA9"

set_property IOSTANDARD LVCMOS33 [get_ports {SIOC}];  # "JA1"
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[6]}];  # "JA10"
set_property IOSTANDARD LVCMOS33 [get_ports {VSYNC}];  # "JA2"
set_property IOSTANDARD LVCMOS33 [get_ports {PCLK}];  # "JA3"
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[7]}];  # "JA4"
set_property IOSTANDARD LVCMOS33 [get_ports {SIOD}];  # "JA7"
set_property IOSTANDARD LVCMOS33 [get_ports {HREF}];  # "JA8"
set_property IOSTANDARD LVCMOS33 [get_ports {XCLK}];  # "JA9"
# set pull up on i2c bus
set_property PULLUP TRUE [get_ports {SIOD}]
set_property PULLUP TRUE [get_ports {SIOC}]

# ----------------------------------------------------------------------------
# JB Pmod - Bank 13
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN W12 [get_ports {DATA[5]}];  # "JB1"
set_property PACKAGE_PIN V8  [get_ports {PWDN}];  # "JB10"
set_property PACKAGE_PIN W11 [get_ports {DATA[3]}];  # "JB2"
set_property PACKAGE_PIN V10 [get_ports {DATA[1]}];  # "JB3"
set_property PACKAGE_PIN W8  [get_ports {RESET}];  # "JB4"
set_property PACKAGE_PIN V12 [get_ports {DATA[4]}];  # "JB7"
set_property PACKAGE_PIN W10 [get_ports {DATA[2]}];  # "JB8"
set_property PACKAGE_PIN V9  [get_ports {DATA[0]}];  # "JB9"

set_property IOSTANDARD LVCMOS33 [get_ports {DATA[5]}];  # "JB1"
set_property IOSTANDARD LVCMOS33 [get_ports {PWDN}];  # "JB10"
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[3]}];  # "JB2"
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[1]}];  # "JB3"
set_property IOSTANDARD LVCMOS33 [get_ports {RESET}];  # "JB4"
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[4]}];  # "JB7"
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[2]}];  # "JB8"
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[0]}];  # "JB9"

create_clock -period 40.000 -name pclk -waveform {0.000 20.000} [get_ports PCLK]
set_input_delay -clock [get_clocks pclk] 20 [get_ports DATA]
set_input_delay -clock [get_clocks pclk] 20 [get_ports VSYNC]
set_input_delay -clock [get_clocks pclk] 20 [get_ports HREF]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets PCLK_IBUF]
set_clock_groups -group [get_clocks {pclk}] -group [get_clocks clk_fpga_1] -logically_exclusive
set_clock_groups -group [get_clocks {pclk}] -group [get_clocks clk_fpga_0] -asynchronous
set_clock_groups -group [get_clocks {clk_fpga_1}] -group [get_clocks clk_fpga_0] -asynchronous

