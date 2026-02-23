#=========================================================================
# compile.tcl
#=========================================================================
# Custom DC compile script for the DNN accelerator.
# Adapted from SramUnit to handle case-insensitive naming (needed for
# SPICE-based LVS which is case-insensitive).
#
# Author : Christopher Torng
# Date   : September 30, 2018

#-------------------------------------------------------------------------
# Pre-compile checks
#-------------------------------------------------------------------------

redirect -tee \
  ${dc_reports_dir}/${dc_design_name}.premapped.checktiming.rpt \
  {check_timing}

check_design -summary
check_design \
  > ${dc_reports_dir}/${dc_design_name}.premapped.checkdesign.rpt

#-------------------------------------------------------------------------
# Compile
#-------------------------------------------------------------------------

puts "Info: DC compile_ultra options = $compile_ultra_options"

eval "compile_ultra $compile_ultra_options"

# High-effort area optimization

if { $dc_high_effort_area_opt == True } {
  optimize_netlist -area
}

#-------------------------------------------------------------------------
# Post-compile
#-------------------------------------------------------------------------

check_design -summary
check_design > ${dc_reports_dir}/${dc_design_name}.mapped.checkdesign.rpt

# Synopsys Formality

set_svf -off

# Uniquify by prefixing every module in the design with the design name

if { $dc_uniquify_with_design_name == True } {
  set uniquify_naming_style "${dc_design_name}_%s_%d"
  uniquify -force
}

# Use naming rules to preserve structs -- case insensitive for LVS

define_name_rules verilog -preserve_struct_ports -case_insensitive

report_names     \
  -rules verilog \
  > ${dc_reports_dir}/${dc_design_name}.mapped.naming.rpt

# Replace special characters with non-special ones before writing out a
# Verilog netlist (e.g., "\bus[5]" -> "bus_5_")

change_names -rules verilog -hierarchy
