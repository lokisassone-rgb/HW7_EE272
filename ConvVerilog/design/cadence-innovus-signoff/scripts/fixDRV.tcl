#=========================================================================
# fixDRV.tcl
#=========================================================================
# Fix persistent DRV (Design Rule Violation) errors after routing.
# This script runs post-route optimization targeting capacitance
# violations. Note: this will not compensate for a poor floorplan.

setOptMode -fixCap true
optDesign  -postRoute
