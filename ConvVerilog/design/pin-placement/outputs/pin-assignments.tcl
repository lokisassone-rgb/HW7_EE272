#=========================================================================
# pin-assignments.tcl
#=========================================================================
# Pin assignments for the conv accelerator.
# Matches left-to-right dataflow floorplan:
#   - Left:   ifmap/weight input data + config data (near left-side SRAMs)
#   - Right:  ofmap output data (near right-side SRAMs)
#   - Top:    control signals (clk, rst_n, vld/rdy handshakes)
#   - Bottom: unused
#
# Metal layers chosen to match edge orientation:
#   - met3 (horizontal) for LEFT/RIGHT edges
#   - met2 (vertical)   for TOP edge
#
# Author : Christopher Torng
# Date   : March 26, 2018

#-------------------------------------------------------------------------
# Pin Assignments
#-------------------------------------------------------------------------

# Top side: control signals only (met2, vertical metal for top edge)

set pins_top {}
lappend pins_top clk rst_n
lappend pins_top ifmap_weight_vld ifmap_weight_rdy
lappend pins_top config_vld config_rdy

# Right side: ofmap data bus + handshake (near ofmap SRAMs on right)

set pins_right {}
for {set i 31} {$i >= 0} {incr i -1} {
  lappend pins_right "ofmap_data\[$i\]"
}
lappend pins_right ofmap_vld ofmap_rdy

# Bottom side: empty

set pins_bottom {}

# Left side: ifmap/weight data bus + config data bus (near input SRAMs on left)

set pins_left {}
for {set i 16} {$i >= 0} {incr i -1} {
  lappend pins_left "ifmap_weight_data\[$i\]"
}
for {set i 15} {$i >= 0} {incr i -1} {
  lappend pins_left "config_data\[$i\]"
}


# Spread the pins evenly along the sides of the block

editPin -layer met3 -pin $pins_left   -side LEFT   -spreadType SIDE
editPin -layer met3 -pin $pins_right  -side RIGHT  -spreadType SIDE
editPin -layer met2 -pin $pins_top    -side TOP    -spreadType SIDE
