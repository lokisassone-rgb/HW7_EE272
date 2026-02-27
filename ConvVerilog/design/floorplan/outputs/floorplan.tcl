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

placeInstance weight_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_0__sram 850 1050 R0
placeInstance weight_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_1__sram 1583 1050 R0

placeInstance ifmap_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_0__sram 37 1500 R0
placeInstance ifmap_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_1__sram 770 1800 R0

placeInstance ofmap_buffer_inst/ram0/genblk1_width_macro_0__sram 1025 90 R0
placeInstance ofmap_buffer_inst/ram0/genblk1_width_macro_1__sram 1025 550 R0
placeInstance ofmap_buffer_inst/ram0/genblk1_width_macro_2__sram 1575 90 R0
placeInstance ofmap_buffer_inst/ram0/genblk1_width_macro_3__sram 1575 550 R0

placeInstance ofmap_buffer_inst/ram1/genblk1_width_macro_0__sram 50 90 R0
placeInstance ofmap_buffer_inst/ram1/genblk1_width_macro_1__sram 50 550 R0
placeInstance ofmap_buffer_inst/ram1/genblk1_width_macro_2__sram 575 90 R0
placeInstance ofmap_buffer_inst/ram1/genblk1_width_macro_3__sram 575 550 R0


addHaloToBlock 5 5 5 5 -allBlock

setDontUse sky130_fd_sc_hd__clkinv_16 true

# Create a routing blockage on li1 layer over the entire chip area, so that 
# Innovus does not use this layer for routing

#createRouteBlk -box {0 0 614 614} -layer {li1}