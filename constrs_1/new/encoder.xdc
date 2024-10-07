####################################################################################################

create_clock -period 10.000 [get_ports clk]
set_clock_uncertainty 0.15 [get_clocks clk]

set_input_delay -clock clk -max 2.000 [get_ports {data_in[*][*]}]
set_output_delay -clock clk -max 2.000 [get_ports {data_out[*][*]}]

####################################################################################################

set_property DONT_TOUCH true [get_cells -hierarchical *]

####################################################################################################