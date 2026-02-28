#=========================================================================
# reporting.tcl
#=========================================================================
# Author : Christopher Torng
# Date   : March 26, 2018

# Report area

report_area -verbose > $vars(rpt_dir)/$vars(step).area.rpt

# Report power

report_power -hierarchy all > power.rpt
