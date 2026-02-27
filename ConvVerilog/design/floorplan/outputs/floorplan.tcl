#=========================================================================
# floorplan.tcl
#=========================================================================
# Author : Christopher Torng
# Date   : March 26, 2018

#-------------------------------------------------------------------------
# Floorplan variables
#-------------------------------------------------------------------------

# Set the floorplan to target a reasonable placement density with a good
# aspect ratio (height:width). An aspect ratio of 2.0 here will make a
# rectangular chip with a height that is twice the width.

set core_aspect_ratio   1.00; # Aspect ratio 1.0 for a square chip
set core_density_target 0.55; # Placement density of 70% is reasonable

# Make room in the floorplan for the core power ring

set pwr_net_list {VDD VSS}; # List of power nets in the core power ring

set M1_min_width   [dbGet [dbGetLayerByZ 1].minWidth]
set M1_min_spacing [dbGet [dbGetLayerByZ 1].minSpacing]

set savedvars(p_ring_width)   [expr 48 * $M1_min_width];   # Arbitrary!
set savedvars(p_ring_spacing) [expr 24 * $M1_min_spacing]; # Arbitrary!

# Core bounding box margins

set core_margin_t [expr ([llength $pwr_net_list] * ($savedvars(p_ring_width) + $savedvars(p_ring_spacing))) + $savedvars(p_ring_spacing)]
set core_margin_b [expr ([llength $pwr_net_list] * ($savedvars(p_ring_width) + $savedvars(p_ring_spacing))) + $savedvars(p_ring_spacing)]
set core_margin_r [expr ([llength $pwr_net_list] * ($savedvars(p_ring_width) + $savedvars(p_ring_spacing))) + $savedvars(p_ring_spacing)]
set core_margin_l [expr ([llength $pwr_net_list] * ($savedvars(p_ring_width) + $savedvars(p_ring_spacing))) + $savedvars(p_ring_spacing)]

#-------------------------------------------------------------------------
# Floorplan
#-------------------------------------------------------------------------

# Calling floorPlan with the "-r" flag sizes the floorplan according to
# the core aspect ratio and a density target (70% is a reasonable
# density).
#

floorPlan -r $core_aspect_ratio $core_density_target \
             $core_margin_l $core_margin_b $core_margin_r $core_margin_t

setFlipping s

# Use automatic floorplan synthesis to pack macros (e.g., SRAMs) together

#planDesign

# ---------------------------------------------------------------
# Macro placement: left-to-right dataflow
#   Left side:  ifmap (top-left, MX=pins face down toward center)
#               weight (bottom-left, R0)
#   Center:     systolic array std cells (auto-placed)
#   Right side: ofmap ram0 (bottom-right), ram1 (top-right), R0
# ---------------------------------------------------------------

# Weight SRAMs (4KB) — bottom-left, R0 orientation
placeInstance weight_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_0__sram 45 190 R0
placeInstance weight_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_1__sram 790 190 R0

# Ifmap SRAMs (4KB) — top-left, MX orientation (flipped so dout faces center)
placeInstance ifmap_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_0__sram 45 1670 MX
placeInstance ifmap_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_1__sram 790 1670 MX

# Ofmap ram0 SRAMs (1KB) — bottom-right, 2x2 grid
placeInstance ofmap_buffer_inst/ram0/genblk1_width_macro_0__sram 1545 80 R0
placeInstance ofmap_buffer_inst/ram0/genblk1_width_macro_1__sram 1545 665 R0
placeInstance ofmap_buffer_inst/ram0/genblk1_width_macro_2__sram 2085 80 R0
placeInstance ofmap_buffer_inst/ram0/genblk1_width_macro_3__sram 2085 665 R0

# Ofmap ram1 SRAMs (1KB) — top-right, 2x2 grid, MX so dout1 faces center
placeInstance ofmap_buffer_inst/ram1/genblk1_width_macro_0__sram 1545 1405 MX
placeInstance ofmap_buffer_inst/ram1/genblk1_width_macro_1__sram 1545 2010 MX
placeInstance ofmap_buffer_inst/ram1/genblk1_width_macro_2__sram 2085 1405 MX
placeInstance ofmap_buffer_inst/ram1/genblk1_width_macro_3__sram 2085 2010 MX

addHaloToBlock 5 5 5 5 -allBlock

# li1 routing blockages around SRAMs — uncomment if DRC shorts on li1 reappear
# foreach inst [dbGet [dbGet top.insts.cell.baseClass block -p2].name] {
#   set box [dbGet [dbGet top.insts.name $inst -p].box]
#   set llx [expr [lindex [lindex $box 0] 0] - 20]
#   set lly [expr [lindex [lindex $box 0] 1] - 20]
#   set urx [expr [lindex [lindex $box 0] 2] + 20]
#   set ury [expr [lindex [lindex $box 0] 3] + 20]
#   createRouteBlk -box "$llx $lly $urx $ury" -layer {li1}
# }

setDontUse sky130_fd_sc_hd__clkinv_16 true
