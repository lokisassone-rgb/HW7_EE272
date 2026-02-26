#=========================================================================
# pin-assignments.tcl
#=========================================================================
# Pin assignments for the conv accelerator.
# Pins are placed to minimize wirelength based on SRAM floorplan:
#   - Top:    ifmap/weight input data (near ifmap/weight SRAMs)
#   - Bottom: ofmap output data (near ofmap SRAMs)
#   - Left:   config data (near controller std cell region)
#   - Right:  unused
#
# Author : Christopher Torng
# Date   : March 26, 2018

#-------------------------------------------------------------------------
# Pin Assignments
#-------------------------------------------------------------------------

# Top side: clk, rst_n, ifmap_weight_data[16:0], ifmap_weight_vld, ifmap_weight_rdy
# (near the ifmap and weight SRAMs at top of floorplan)

# Pins on the top side. The first pin in this list (here dout1[31]) is on the
# top left and the last pin is on the top right.

set pins_top {}
lappend pins_top clk rst_n
for {set i 16} {$i >= 0} {incr i -1} {
  lappend pins_top "ifmap_weight_data\[$i\]"
}
lappend pins_top ifmap_weight_vld ifmap_weight_rdy
# Pins on the right side. In this example we are not placing pins on the right
# side, since we haven't routed out the pins on the right side of the SRAM. In
# your design, you can use the right side as well.

set pins_right {}

# Pins on the bottom side from right (dout0[0]) to left (din0[31]). I list pins
# out explicitly here because the dout0 and din0 pins on the SRAM macro are
# interleaved somewhat randomly, but if in your case the pins of the same bus
# are to be kept together then you can generate this pin list using a tcl for
# loop.

set pins_bottom {}
for {set i 31} {$i >= 0} {incr i -1} {
  lappend pins_bottom "ofmap_data\[$i\]"
}
lappend pins_bottom ofmap_vld ofmap_rdy

# Pins on the left side from bottom (rst_n) to top (addr0[0]).

set pins_left {}
for {set i 15} {$i >= 0} {incr i -1} {
  lappend pins_left "config_data\[$i\]"
}
lappend pins_left config_vld config_rdy


# Spread the pins evenly along the sides of the block

editPin -layer met2 -pin $pins_top    -side TOP    -spreadType SIDE
editPin -layer met2 -pin $pins_bottom -side BOTTOM -spreadType SIDE
editPin -layer met3 -pin $pins_left   -side LEFT   -spreadType SIDE
