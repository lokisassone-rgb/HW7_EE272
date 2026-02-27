#=========================================================================
# fixDRV.tcl -- Post-route optimization to fix DRV/timing violations
#=========================================================================
# Runs before signoff to clean up marginal setup violations and
# design rule violations (cap, transition, fanout).

setOptMode -fixCap true
setOptMode -fixTran true
setOptMode -fixFanoutLoad true
setOptMode -usefulSkew true
setOptMode -effort high

optDesign -postRoute -setup
optDesign -postRoute -setup
