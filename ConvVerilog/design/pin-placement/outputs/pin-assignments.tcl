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

set pins_top {}
lappend pins_top clk rst_n
for {set i 16} {$i >= 0} {incr i -1} {
  lappend pins_top "ifmap_weight_data\[$i\]"
}
lappend pins_top ifmap_weight_vld ifmap_weight_rdy

# Bottom side: ofmap_data[31:0], ofmap_vld, ofmap_rdy
# (near the ofmap SRAMs at bottom of floorplan)

set pins_bottom {}
for {set i 31} {$i >= 0} {incr i -1} {
  lappend pins_bottom "ofmap_data\[$i\]"
}
lappend pins_bottom ofmap_vld ofmap_rdy

# Left side: config_data[15:0], config_vld, config_rdy
# (near the open std cell area where the controller is placed)

set pins_left {}
for {set i 15} {$i >= 0} {incr i -1} {
  lappend pins_left "config_data\[$i\]"
}
lappend pins_left config_vld config_rdy

# Right side: no pins

set pins_right {}

# Spread the pins evenly along each side

editPin -layer met2 -pin $pins_top    -side TOP    -spreadType SIDE
editPin -layer met2 -pin $pins_bottom -side BOTTOM -spreadType SIDE
editPin -layer met3 -pin $pins_left   -side LEFT   -spreadType SIDE

