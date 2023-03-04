## basys3 breakout board
set_property PACKAGE_PIN W5 [get_ports clk]
set_property PACKAGE_PIN V17 [get_ports rst]
set_property PACKAGE_PIN U16 [get_ports io_led[0]]
set_property PACKAGE_PIN E19 [get_ports io_led[1]]
set_property PACKAGE_PIN U19 [get_ports io_led[2]]
set_property PACKAGE_PIN V19 [get_ports io_led[3]]

set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports io_led[0]]
set_property IOSTANDARD LVCMOS33 [get_ports io_led[1]]
set_property IOSTANDARD LVCMOS33 [get_ports io_led[2]]
set_property IOSTANDARD LVCMOS33 [get_ports io_led[3]]
