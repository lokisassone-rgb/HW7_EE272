#=========================================================================
# Post-route optimization -- fix small timing/DRV violations
#=========================================================================
# This script runs after route to clean up marginal setup violations
# and design rule violations (cap, transition, fanout).

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

mkdir -p outputs
saveDesign outputs/design.checkpoint/
