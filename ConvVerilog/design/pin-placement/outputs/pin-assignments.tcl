#=========================================================================
# pin-assignments.tcl
#=========================================================================
# Assign I/O pins for the DNN accelerator (conv) design.
#
# Ports:
#   clk, rst_n
#   ifmap_weight_data[16:0], ifmap_weight_rdy, ifmap_weight_vld
#   ofmap_data[31:0], ofmap_rdy, ofmap_vld
#   config_data[15:0], config_rdy, config_vld

#-------------------------------------------------------------------------
# Pin Assignments
#-------------------------------------------------------------------------

# Left side: clock, reset, and input data
set pins_left {clk rst_n ifmap_weight_vld ifmap_weight_rdy}
for {set i 16} {$i >= 0} {incr i -1} {
  lappend pins_left "ifmap_weight_data[$i]"
}

# Bottom side: config data
set pins_bottom {config_vld config_rdy}
for {set i 15} {$i >= 0} {incr i -1} {
  lappend pins_bottom "config_data[$i]"
}

# Right side: output data
set pins_right {ofmap_vld ofmap_rdy}
for {set i 31} {$i >= 0} {incr i -1} {
  lappend pins_right "ofmap_data[$i]"
}

# Spread pins evenly along each side
editPin -layer met3 -pin $pins_left   -side LEFT   -spreadType SIDE
editPin -layer met2 -pin $pins_bottom -side BOTTOM -spreadType SIDE
editPin -layer met3 -pin $pins_right  -side RIGHT  -spreadType SIDE
