#=========================================================================
# START.tcl
#=========================================================================
# Author : Christopher Torng
# Date   : January 14, 2020

#-------------------------------------------------------------------------
# Setup
#-------------------------------------------------------------------------

source innovus-foundation-flow/custom-scripts/restore-design.tcl
source innovus-foundation-flow/custom-scripts/setup-session.tcl

#-------------------------------------------------------------------------
# Execute
#-------------------------------------------------------------------------

set order [split $::env(order) ","]

foreach tcl $order {
  if {[ file exists inputs/$tcl ]} {
    puts "\n  > Info: Sourcing \"inputs/$tcl\"\n"
    source -verbose inputs/$tcl
  } elseif {[ file exists scripts/$tcl ]} {
    puts "\n  > Info: Sourcing \"scripts/$tcl\"\n"
    source -verbose scripts/$tcl
  } else {
    echo "Warn: Did not find $tcl"
    exit 1
  }
}

#-------------------------------------------------------------------------
# Clean up
#-------------------------------------------------------------------------

source innovus-foundation-flow/custom-scripts/save-design.tcl

exit
