#=========================================================================
# main.tcl
#=========================================================================
# A generic power strategy that should work for most designs
#
# Author : Christopher Torng
# Date   : January 13, 2020

#-------------------------------------------------------------------------
# Implement power strategy
#-------------------------------------------------------------------------

set M2_direction [dbGet [dbGet head.layers.name 3 -p].direction]

if { $M2_direction == "Vertical" } {
  puts "Info: Using coarse-only power mesh because M2 is vertical"
  if {[ file exists inputs/power-strategy-singlemesh.tcl ]} {
    source -verbose inputs/power-strategy-singlemesh.tcl
  } else {
    source -verbose scripts/power-strategy-singlemesh.tcl
  }
} else {
  puts "Info: Using fine+coarse power mesh because M2 is horizontal"
  if {[ file exists inputs/power-strategy-dualmesh.tcl ]} {
    source -verbose inputs/power-strategy-dualmesh.tcl
  } else {
    source -verbose scripts/power-strategy-dualmesh.tcl
  }
}
