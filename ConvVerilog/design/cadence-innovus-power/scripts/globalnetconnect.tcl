#=========================================================================
# globalnetconnect.tcl
#=========================================================================
# Connect power/ground nets to the correct pin names.
# SkyWater stdcells use VPWR/VGND instead of VDD/VSS.
# SRAM macros use vccd1/vssd1.

globalNetConnect VDD    -type pgpin -pin VPWR    -inst * -verbose
globalNetConnect VSS    -type pgpin -pin VGND    -inst * -verbose
globalNetConnect VSS    -type pgpin -pin VNB     -inst * -verbose
globalNetConnect VDD    -type pgpin -pin VPB     -inst * -verbose

globalNetConnect VDD    -type pgpin -pin vccd1   -inst * -verbose
globalNetConnect VSS    -type pgpin -pin vssd1   -inst * -verbose
