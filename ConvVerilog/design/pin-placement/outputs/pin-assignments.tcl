#=========================================================================
# pin-assignments.tcl
#=========================================================================
# Pin assignments for the conv accelerator.
# Pins are placed to minimize wirelength based on SRAM floorplan:
#   - Top:    control/handshake signals
#   - Bottom: ofmap output data (near 8 ofmap SRAMs spanning bottom)
#   - Left:   ifmap/weight + config data (near ifmap SRAMs top-left,
#             controller std cells mid-left)
#   - Right:  unused
#
# Author : Christopher Torng
# Date   : March 26, 2018

#-------------------------------------------------------------------------
# Pin Assignments
#-------------------------------------------------------------------------

# Top side: clk, rst_n, handshake/control signals
# (spread across top edge, short routes to logic)

set pins_top {}
lappend pins_top rst_n ifmap_weight_rdy ifmap_weight_vld
lappend pins_top clk
lappend pins_top config_rdy config_vld

# Bottom side: ofmap_data[31:0], ofmap_vld, ofmap_rdy
# (near the 8 ofmap SRAMs spanning the entire bottom: ram0 bottom-right,
#  ram1 bottom-left)

set pins_bottom {}
for {set i 31} {$i >= 0} {incr i -1} {
  lappend pins_bottom "ofmap_data\[$i\]"
}
lappend pins_bottom ofmap_vld ofmap_rdy

# Left side: ifmap_weight_data[15:0], config_data[15:0]
# (ifmap SRAMs at top-left, controller std cells in open area mid-left)

set pins_left {}
for {set i 15} {$i >= 0} {incr i -1} {
  lappend pins_left "ifmap_weight_data\[$i\]"
}
for {set i 15} {$i >= 0} {incr i -1} {
  lappend pins_left "config_data\[$i\]"
}

# Right side: no pins

set pins_right {}

# Spread the pins evenly along each side

editPin -layer met2 -pin $pins_top    -side TOP    -spreadType SIDE
editPin -layer met2 -pin $pins_bottom -side BOTTOM -spreadType SIDE
editPin -layer met3 -pin $pins_left   -side LEFT   -spreadType SIDE

