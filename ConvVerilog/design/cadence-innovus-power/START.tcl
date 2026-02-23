#=========================================================================
# START.tcl
#=========================================================================
# Runs the scripts for this step.
#
# Author : Christopher Torng
# Date   : January 14, 2020

#-------------------------------------------------------------------------
# Setup
#-------------------------------------------------------------------------
# Restore from checkpoint and set up variables

source innovus-foundation-flow/custom-scripts/restore-design.tcl
source innovus-foundation-flow/custom-scripts/setup-session.tcl

#-------------------------------------------------------------------------
# Execute
#-------------------------------------------------------------------------

# Order is a comma-separated string containing scripts to run

set order [split $::env(order) ","]

# Run the scripts in order (inputs take priority)

foreach tcl $order {
  # Try to find the script in the "inputs" directory first
  if {[ file exists inputs/$tcl ]} {
    puts "\n  > Info: Sourcing \"inputs/$tcl\"\n"
    source -verbose inputs/$tcl
  # Try to find the script in the "scripts" directory
  } elseif {[ file exists scripts/$tcl ]} {
    puts "\n  > Info: Sourcing \"scripts/$tcl\"\n"
    source -verbose scripts/$tcl
  # Failed to find the script anywhere...
  } else {
    echo "Warn: Did not find $tcl"
    exit 1
  }
}

#-------------------------------------------------------------------------
# Clean up
#-------------------------------------------------------------------------
# Save a new checkpoint and clean up

source innovus-foundation-flow/custom-scripts/save-design.tcl

exit
