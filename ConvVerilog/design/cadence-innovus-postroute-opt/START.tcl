#=========================================================================
# Post-route optimization -- fix small timing/DRV violations
#=========================================================================
# This script runs after route to clean up marginal setup violations
# and design rule violations (cap, transition, fanout).

#-------------------------------------------------------------------------
# Setup -- restore design from previous step
#-------------------------------------------------------------------------

source innovus-foundation-flow/custom-scripts/restore-design.tcl
source innovus-foundation-flow/custom-scripts/setup-session.tcl

#-------------------------------------------------------------------------
# Fix DRV and setup violations
#-------------------------------------------------------------------------

setOptMode -fixCap true
setOptMode -fixTran true
setOptMode -fixFanoutLoad true

optDesign -postRoute
optDesign -postRoute -setup

#-------------------------------------------------------------------------
# Save the design checkpoint
#-------------------------------------------------------------------------

mkdir -p checkpoints
saveDesign checkpoints/design.checkpoint/

exit
