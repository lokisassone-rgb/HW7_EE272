#=========================================================================
# floorplan.tcl
#=========================================================================
# Floorplan for DNN accelerator with 12 SRAM macros:
#   - 4x 4KB SRAMs (sky130_sram_4kbyte_1rw1r_32x1024_8) for weight/ifmap buffers
#   - 8x 1KB SRAMs (sky130_sram_1kbyte_1rw1r_32x256_8) for accumulation buffers
#
# SRAM hierarchy (from the RTL):
#   weight_double_buffer_inst/ram/depth_macro[*].width_macro[*].sram  (2x 4KB)
#   ifmap_double_buffer_inst/ram/depth_macro[*].width_macro[*].sram   (2x 4KB)
#   ofmap_buffer_inst/ram0/width_macro[*].sram                        (4x 1KB)
#   ofmap_buffer_inst/ram1/width_macro[*].sram                        (4x 1KB)

#-------------------------------------------------------------------------
# Floorplan variables
#-------------------------------------------------------------------------

set core_aspect_ratio   1.00; # Square chip
set core_density_target 0.30; # Start conservative (0.30 for 80pts, 0.55 for 100pts)

# Power ring sizing

set pwr_net_list {VDD VSS}

set M1_min_width   [dbGet [dbGetLayerByZ 1].minWidth]
set M1_min_spacing [dbGet [dbGetLayerByZ 1].minSpacing]

set savedvars(p_ring_width)   [expr 48 * $M1_min_width]
set savedvars(p_ring_spacing) [expr 24 * $M1_min_spacing]

# Core bounding box margins (space for power rings)

set core_margin_t [expr ([llength $pwr_net_list] * ($savedvars(p_ring_width) + $savedvars(p_ring_spacing))) + $savedvars(p_ring_spacing)]
set core_margin_b [expr ([llength $pwr_net_list] * ($savedvars(p_ring_width) + $savedvars(p_ring_spacing))) + $savedvars(p_ring_spacing)]
set core_margin_r [expr ([llength $pwr_net_list] * ($savedvars(p_ring_width) + $savedvars(p_ring_spacing))) + $savedvars(p_ring_spacing)]
set core_margin_l [expr ([llength $pwr_net_list] * ($savedvars(p_ring_width) + $savedvars(p_ring_spacing))) + $savedvars(p_ring_spacing)]

#-------------------------------------------------------------------------
# Floorplan
#-------------------------------------------------------------------------

floorPlan -r $core_aspect_ratio $core_density_target \
             $core_margin_l $core_margin_b $core_margin_r $core_margin_t

setFlipping s

# Use planDesign to automatically place all 12 SRAM macros.
# This is the safest starting point -- Innovus will find reasonable
# locations for all macros. You can replace this with manual placeInstance
# commands later if you want more control.

#planDesign

# Add halos around all macros to keep stdcells away from SRAM edges.
# This prevents DRC violations and routing congestion near macros.

#addHaloToBlock 10.88 10.88 10.88 10.88 -allBlock

placeInstance weight_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_0__sram 37 202 R0
placeInstance weight_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_1__sram 770 202 R0
placeInstance ifmap_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_0__sram 37 1635 MX
placeInstance ifmap_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_1__sram 770 1635 MX
placeInstance ofmap_buffer_inst/ram0/genblk1_width_macro_0__sram 1525.0000 70.0000 R0
placeInstance ofmap_buffer_inst/ram0/genblk1_width_macro_1__sram 1525.0000 651.0000 R0
placeInstance ofmap_buffer_inst/ram0/genblk1_width_macro_2__sram 2075.0000 90.0000 R0
placeInstance ofmap_buffer_inst/ram0/genblk1_width_macro_3__sram 2075.0000 651.0000 R0
placeInstance ofmap_buffer_inst/ram1/genblk1_width_macro_0__sram 1527.0000 1393.0000 R0
placeInstance ofmap_buffer_inst/ram1/genblk1_width_macro_1__sram 1527.0000 2016.0000 R0
placeInstance ofmap_buffer_inst/ram1/genblk1_width_macro_2__sram 2075.0000 1393.0000 R0
placeInstance ofmap_buffer_inst/ram1/genblk1_width_macro_3__sram 2075.0000 2016.0000 R0

addHaloToBlock 5 5 5 5 weight_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_0__sram
addHaloToBlock 5 5 5 5 weight_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_1__sram 
addHaloToBlock 5 5 5 5 ifmap_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_0__sram
addHaloToBlock 5 5 5 5 ifmap_double_buffer_inst/ram/genblk1_width_macro_0__depth_macro_1__sram 
addHaloToBlock 5 5 5 5 ofmap_buffer_inst/ram0/genblk1_width_macro_0__sram 
addHaloToBlock 5 5 5 5 ofmap_buffer_inst/ram0/genblk1_width_macro_1__sram 
addHaloToBlock 5 5 5 5 ofmap_buffer_inst/ram0/genblk1_width_macro_2__sram 
addHaloToBlock 5 5 5 5 ofmap_buffer_inst/ram0/genblk1_width_macro_3__sram 
addHaloToBlock 5 5 5 5 ofmap_buffer_inst/ram1/genblk1_width_macro_0__sram 
addHaloToBlock 5 5 5 5 ofmap_buffer_inst/ram1/genblk1_width_macro_1__sram 
addHaloToBlock 5 5 5 5 ofmap_buffer_inst/ram1/genblk1_width_macro_2__sram 
addHaloToBlock 5 5 5 5 ofmap_buffer_inst/ram1/genblk1_width_macro_3__sram 

setDontUse sky130_fd_sc_hd__clkinv_16 true
