#=========================================================================
# power-strategy-singlemesh.tcl
#=========================================================================
# Power mesh for DNN accelerator with 12 SRAM macros.
# Adapted from SramUnit's power strategy.

#-------------------------------------------------------------------------
# Stdcell power rail preroute
#-------------------------------------------------------------------------

sroute -nets {VDD VSS}

#-------------------------------------------------------------------------
# Shorter names from the ADK
#-------------------------------------------------------------------------

set pmesh_bot $ADK_POWER_MESH_BOT_LAYER
set pmesh_top $ADK_POWER_MESH_TOP_LAYER

#-------------------------------------------------------------------------
# Power ring around the core
#-------------------------------------------------------------------------

addRing -nets {VDD VSS} -type core_rings -follow core   \
        -layer [list top  $pmesh_top bottom $pmesh_top  \
                     left $pmesh_bot right  $pmesh_bot] \
        -width $savedvars(p_ring_width)                 \
        -spacing $savedvars(p_ring_spacing)             \
        -offset $savedvars(p_ring_spacing)              \
        -extend_corner {tl tr bl br lt lb rt rb}

#-------------------------------------------------------------------------
# Block rings around all SRAM macros
#-------------------------------------------------------------------------
# Select all macro instances and add power rings around each one

selectInst *sram*
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 \
  -avoid_short 0 -skip_crossing_trunks none \
  -stacked_via_top_layer met5 -stacked_via_bottom_layer met4 \
  -via_using_exact_crossover_size 1 -orthogonal_only true \
  -skip_via_on_pin { standardcell } \
  -skip_via_on_wire_shape { noshape }

addRing -nets {VDD VSS} -type block_rings -around selected \
  -layer {top met5 bottom met5 left met4 right met4} \
  -width {top 1.8 bottom 1.8 left 1.8 right 1.8} \
  -spacing {top 1.8 bottom 1.8 left 1.8 right 1.8} \
  -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} \
  -center 0 -threshold 0 -jog_distance 0 \
  -snap_wire_center_to_grid None

deselectAll

#-------------------------------------------------------------------------
# Power mesh bottom settings (vertical)
#-------------------------------------------------------------------------

set M1_min_width    [dbGet [dbGetLayerByZ 2].minWidth]
set M1_route_pitchX [dbGet [dbGetLayerByZ 2].pitchX]

set pmesh_bot_str_width [expr  8 *  3 * $M1_min_width   ]
set pmesh_bot_str_pitch [expr 4 * 10 * $M1_route_pitchX]

set pmesh_bot_str_intraset_spacing [expr $pmesh_bot_str_pitch - $pmesh_bot_str_width]
set pmesh_bot_str_interset_pitch   [expr 4*$pmesh_bot_str_pitch]

setViaGenMode -reset
setViaGenMode -viarule_preference default
setViaGenMode -ignore_DRC false

setAddStripeMode -reset
setAddStripeMode -stacked_via_bottom_layer met1 \
                 -stacked_via_top_layer    $pmesh_top \
                 -break_at { block_ring }

addStripe -nets {VSS VDD} -layer $pmesh_bot -direction vertical \
    -width $pmesh_bot_str_width                                 \
    -spacing $pmesh_bot_str_intraset_spacing                    \
    -set_to_set_distance $pmesh_bot_str_interset_pitch          \
    -max_same_layer_jog_length $pmesh_bot_str_pitch             \
    -padcore_ring_bottom_layer_limit $pmesh_bot                 \
    -padcore_ring_top_layer_limit $pmesh_top                    \
    -start [expr 2*$pmesh_bot_str_pitch]

#-------------------------------------------------------------------------
# Power mesh top settings (horizontal)
#-------------------------------------------------------------------------

set pmesh_top_str_width [expr  8 *  3 * $M1_min_width   ]
set pmesh_top_str_pitch [expr 4 * 10 * $M1_route_pitchX]

set pmesh_top_str_intraset_spacing [expr $pmesh_top_str_pitch - $pmesh_top_str_width]
set pmesh_top_str_interset_pitch   [expr 4*$pmesh_top_str_pitch]

setViaGenMode -reset
setViaGenMode -viarule_preference default
setViaGenMode -ignore_DRC false

setAddStripeMode -reset
setAddStripeMode -stacked_via_bottom_layer $pmesh_bot \
                 -stacked_via_top_layer    $pmesh_top \
                 -break_at { block_ring }

addStripe -nets {VSS VDD} -layer $pmesh_top -direction horizontal \
    -width $pmesh_top_str_width                                   \
    -spacing $pmesh_top_str_intraset_spacing                      \
    -set_to_set_distance $pmesh_top_str_interset_pitch            \
    -max_same_layer_jog_length $pmesh_top_str_pitch               \
    -padcore_ring_bottom_layer_limit $pmesh_bot                   \
    -padcore_ring_top_layer_limit $pmesh_top                      \
    -block_ring_bottom_layer_limit met4                           \
    -start [expr $pmesh_top_str_pitch]

#-------------------------------------------------------------------------
# Route power to all SRAM macro pins
#-------------------------------------------------------------------------

sroute -connect {blockPin} -layerChangeRange {met1 met5} \
  -blockPinTarget { nearestTarget } -nets {VDD VSS} \
  -allowLayerChange 1 -blockPin useLef
