#=========================================================================
# pin-assignments.tcl
#=========================================================================
# Pin assignments for the conv accelerator.
#   - Top:    ofmap data + ofmap handshake
#   - Left:   clk, rst_n, ifmap/weight handshake, config handshake
#   - Bottom: ifmap/weight data, config data
#   - Right:  unused
#
# Metal layers chosen to match edge orientation:
#   - met3 (horizontal) for LEFT/RIGHT edges
#   - met2 (vertical)   for TOP/BOTTOM edges
#
# Author : Christopher Torng
# Date   : March 26, 2018

#-------------------------------------------------------------------------
# Pin Assignments
#-------------------------------------------------------------------------

# Top side: ofmap data bus + handshake (met2, vertical metal for top edge)

set pins_top {}
for {set i 31} {$i >= 0} {incr i -1} {
  lappend pins_top "ofmap_data\[$i\]"
}
lappend pins_top ofmap_vld ofmap_rdy

# Left side: clk, rst_n, handshake signals spread evenly (met3, horizontal metal)

set pins_left {}
lappend pins_left clk rst_n
lappend pins_left ifmap_weight_vld ifmap_weight_rdy
lappend pins_left config_vld config_rdy

# Bottom side: ifmap/weight data, config data (met2, vertical metal)

set pins_bottom {}
for {set i 16} {$i >= 0} {incr i -1} {
  lappend pins_bottom "ifmap_weight_data\[$i\]"
}
for {set i 15} {$i >= 0} {incr i -1} {
  lappend pins_bottom "config_data\[$i\]"
}

# Right side: empty

set pins_right {}


# Spread the pins evenly along the sides of the block

editPin -layer met2 -pin $pins_top    -side TOP    -spreadType SIDE
editPin -layer met3 -pin $pins_left   -side LEFT   -spreadType SIDE
editPin -layer met2 -pin $pins_bottom -side BOTTOM -spreadType SIDE
