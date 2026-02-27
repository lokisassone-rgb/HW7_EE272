#=========================================================================
# pin-assignments.tcl
#=========================================================================
# Pin assignments for the conv accelerator.
#   - Top:    ofmap data + ofmap handshake
#   - Left:   clk, rst_n
#   - Bottom: ifmap/weight data + handshake, config data + handshake
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

# Left side: clk and rst_n spread evenly (met3, horizontal metal for left edge)
# Compute die height and place pins at 1/3 and 2/3 of the left edge

set pins_left {}
lappend pins_left clk rst_n

set die_box [dbGet top.fPlan.box]
set die_lly [lindex [lindex $die_box 0] 1]
set die_ury [lindex [lindex $die_box 0] 3]
set die_height [expr $die_ury - $die_lly]
set left_range_start [expr $die_lly + $die_height / 3.0]
set left_range_end   [expr $die_lly + 2.0 * $die_height / 3.0]

# Bottom side: ifmap/weight data + handshake, config data + handshake (met2, vertical metal)

set pins_bottom {}
for {set i 16} {$i >= 0} {incr i -1} {
  lappend pins_bottom "ifmap_weight_data\[$i\]"
}
lappend pins_bottom ifmap_weight_vld ifmap_weight_rdy
for {set i 15} {$i >= 0} {incr i -1} {
  lappend pins_bottom "config_data\[$i\]"
}
lappend pins_bottom config_vld config_rdy

# Right side: empty

set pins_right {}


# Spread the pins evenly along the sides of the block

editPin -layer met2 -pin $pins_top    -side TOP    -spreadType SIDE
editPin -layer met3 -pin $pins_left   -side LEFT   -spreadType RANGE -spreadDirection clockwise -offsetStart $left_range_start -offsetEnd $left_range_end
editPin -layer met2 -pin $pins_bottom -side BOTTOM -spreadType SIDE
