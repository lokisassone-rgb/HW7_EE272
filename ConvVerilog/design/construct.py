#! /usr/bin/env python
#=========================================================================
# construct.py
#=========================================================================
# DNN accelerator -- Full RTL-to-GDS flow
#
# Author : Kalhan Koul
# Date   : Feb 13, 2021
# Updated: Added PnR flow (Innovus init/place/cts/route/signoff)
#

import os
import sys

from mflowgen.components import Graph, Step

def construct():

  g = Graph()
  g.sys_path.append( '/farmshare/home/classes/ee/272' )

  #-----------------------------------------------------------------------
  # Parameters
  #-----------------------------------------------------------------------

  adk_name = 'skywater-130nm-adk.v2021'
  adk_view = 'view-standard'

  parameters = {
    'construct_path' : __file__,
    'design_name'    : 'conv',
    'clock_period'   : 10.0,
    'adk'            : adk_name,
    'adk_view'       : adk_view,
    'topographical'  : True,
    'testbench_name' : 'conv_tb',
    'strip_path'     : 'conv_tb/conv_inst',
    'saif_instance'  : 'conv_tb/conv_inst'
  }

  #-----------------------------------------------------------------------
  # Create nodes
  #-----------------------------------------------------------------------

  this_dir = os.path.dirname( os.path.abspath( __file__ ) )

  # ADK step

  g.set_adk( adk_name )
  adk = g.get_adk_step()

  # Custom steps -- these are local directories with configure.yml files

  sram            = Step( this_dir + '/sram'                    )
  rtl             = Step( this_dir + '/rtl'                     )
  testbench       = Step( this_dir + '/testbench'               )
  constraints     = Step( this_dir + '/constraints'             )
  rtl_sim         = Step( this_dir + '/cadence-xcelium-sim'     )
  rtl_sim_vcs     = Step( this_dir + '/synopsys-vcs-sim'        )
  syn_compile     = Step( this_dir + '/synopsys-dc-compile'     )  # custom DC compile for case-insensitive naming
  pin_placement   = Step( this_dir + '/pin-placement'           )  # custom pin assignments
  floorplan       = Step( this_dir + '/floorplan'               )  # custom floorplan with SRAM placement
  postroute_opt   = Step( this_dir + '/cadence-innovus-postroute-opt' )  # post-route DRV/timing fix

  # Custom power node -- SkyWater stdcells use VPWR/VGND instead of
  # VDD/VSS, and the layer stack is different because of the li1 layer
  power           = Step( this_dir + '/cadence-innovus-power'   )

  # Custom signoff node -- outputs DEF for LVS
  signoff         = Step( this_dir + '/cadence-innovus-signoff' )

  # Default steps -- these come from the mflowgen built-in step library

  info            = Step( 'info',                          default=True )
  dc              = Step( 'synopsys-dc-synthesis',         default=True )
  iflow           = Step( 'cadence-innovus-flowsetup',     default=True )
  init            = Step( 'cadence-innovus-init',          default=True )
  place           = Step( 'cadence-innovus-place',         default=True )
  cts             = Step( 'cadence-innovus-cts',           default=True )
  postcts_hold    = Step( 'cadence-innovus-postcts_hold',  default=True )
  route           = Step( 'cadence-innovus-route',         default=True )
  postroute       = Step( 'cadence-innovus-postroute',     default=True )
  gdsmerge        = Step( 'mentor-calibre-gdsmerge',       default=True )

  #-----------------------------------------------------------------------
  # Graph -- Add nodes
  #-----------------------------------------------------------------------

  g.add_step( info            )
  g.add_step( sram            )
  g.add_step( rtl             )
  g.add_step( testbench       )
  g.add_step( rtl_sim         )
  g.add_step( rtl_sim_vcs     )
  g.add_step( constraints     )
  g.add_step( syn_compile     )
  g.add_step( dc              )
  g.add_step( iflow           )
  g.add_step( pin_placement   )
  g.add_step( floorplan       )
  g.add_step( init            )
  g.add_step( power           )
  g.add_step( place           )
  g.add_step( cts             )
  g.add_step( postcts_hold    )
  g.add_step( route           )
  g.add_step( postroute       )
  g.add_step( postroute_opt   )
  g.add_step( signoff         )
  g.add_step( gdsmerge        )

  #-----------------------------------------------------------------------
  # Graph -- Add edges
  #-----------------------------------------------------------------------

  # --- Tell DC about the SRAM .db and .lef files ---
  # DC needs .db (timing) to know SRAM delays, and .lef (physical) to
  # know SRAM sizes for area estimation during synthesis.

  dc.extend_inputs(['sky130_sram_4kbyte_1rw1r_32x1024_8_TT_1p8V_25C.db'])
  dc.extend_inputs(['sky130_sram_4kbyte_1rw1r_32x1024_8.lef'])
  dc.extend_inputs(['sky130_sram_1kbyte_1rw1r_32x256_8_TT_1p8V_25C.db'])
  dc.extend_inputs(['sky130_sram_1kbyte_1rw1r_32x256_8.lef'])
  dc.extend_inputs(['compile.tcl'])

  # --- Tell Innovus steps about SRAM .lib and .lef files ---
  # Every Innovus step needs to know the SRAM timing (.lib) and physical
  # (.lef) views so it can correctly handle them during PnR.

  for step in [iflow, init, power, place, cts, postcts_hold, route, postroute, postroute_opt, signoff]:
    step.extend_inputs(['sky130_sram_4kbyte_1rw1r_32x1024_8_TT_1p8V_25C.lib',
                        'sky130_sram_4kbyte_1rw1r_32x1024_8.lef'])
    step.extend_inputs(['sky130_sram_1kbyte_1rw1r_32x256_8_TT_1p8V_25C.lib',
                        'sky130_sram_1kbyte_1rw1r_32x256_8.lef'])

  # --- Tell GDS merge about SRAM .gds files ---
  # The final GDS needs to include the SRAM macro layouts
  gdsmerge.extend_inputs(['sky130_sram_4kbyte_1rw1r_32x1024_8.gds'])
  gdsmerge.extend_inputs(['sky130_sram_1kbyte_1rw1r_32x256_8.gds'])

  # --- Tell init step about our custom floorplan and pin placement ---
  init.extend_inputs(['floorplan.tcl', 'pin-assignments.tcl'])

  # --- Simulation inputs ---

  rtl_sim.extend_inputs(['ifmap_data.txt'])
  rtl_sim.extend_inputs(['weight_data.txt'])
  rtl_sim.extend_inputs(['ofmap_data.txt'])
  rtl_sim.extend_inputs(['layer_params.v'])
  rtl_sim.extend_inputs(['sky130_sram_4kbyte_1rw1r_32x1024_8.v'])
  rtl_sim.extend_inputs(['sky130_sram_2kbyte_1rw1r_32x512_8.v'])
  rtl_sim.extend_inputs(['sky130_sram_1kbyte_1rw1r_32x256_8.v'])

  rtl_sim_vcs.extend_inputs(['ifmap_data.txt'])
  rtl_sim_vcs.extend_inputs(['weight_data.txt'])
  rtl_sim_vcs.extend_inputs(['ofmap_data.txt'])
  rtl_sim_vcs.extend_inputs(['layer_params.v'])
  rtl_sim_vcs.extend_inputs(['sky130_sram_4kbyte_1rw1r_32x1024_8.v'])
  rtl_sim_vcs.extend_inputs(['sky130_sram_2kbyte_1rw1r_32x512_8.v'])
  rtl_sim_vcs.extend_inputs(['sky130_sram_1kbyte_1rw1r_32x256_8.v'])

  # extend saif out of synopsys simulation
  rtl_sim_vcs.extend_outputs(['run.saif'])

  #-----------------------------------------------------------------------
  # Graph -- Connect by name
  #-----------------------------------------------------------------------

  # --- Simulation connections ---
  g.connect_by_name( rtl,          rtl_sim      )
  g.connect_by_name( sram,         rtl_sim      )
  g.connect_by_name( testbench,    rtl_sim      )
  g.connect_by_name( rtl,          rtl_sim_vcs  )
  g.connect_by_name( sram,         rtl_sim_vcs  )
  g.connect_by_name( testbench,    rtl_sim_vcs  )

  # --- Synthesis connections ---
  g.connect_by_name( rtl_sim_vcs,  dc           ) # run.saif for power
  g.connect_by_name( rtl,          dc           ) # design.v
  g.connect_by_name( adk,          dc           ) # technology libs
  g.connect_by_name( constraints,  dc           ) # constraints.tcl
  g.connect_by_name( sram,         dc           ) # SRAM .db and .lef
  g.connect_by_name( syn_compile,  dc           ) # custom compile.tcl

  # --- ADK goes to all Innovus steps ---
  g.connect_by_name( adk,          iflow        )
  g.connect_by_name( adk,          init         )
  g.connect_by_name( adk,          power        )
  g.connect_by_name( adk,          place        )
  g.connect_by_name( adk,          cts          )
  g.connect_by_name( adk,          postcts_hold )
  g.connect_by_name( adk,          route        )
  g.connect_by_name( adk,          postroute    )
  g.connect_by_name( adk,          postroute_opt)
  g.connect_by_name( adk,          signoff      )
  g.connect_by_name( adk,          gdsmerge     )

  # --- SRAM files go to all Innovus steps ---
  g.connect_by_name( sram,         iflow        )
  g.connect_by_name( sram,         init         )
  g.connect_by_name( sram,         power        )
  g.connect_by_name( sram,         place        )
  g.connect_by_name( sram,         cts          )
  g.connect_by_name( sram,         postcts_hold )
  g.connect_by_name( sram,         route        )
  g.connect_by_name( sram,         postroute    )
  g.connect_by_name( sram,         postroute_opt)
  g.connect_by_name( sram,         signoff      )
  g.connect_by_name( sram,         gdsmerge     )

  # --- DC outputs go to Innovus ---
  g.connect_by_name( dc,           iflow        )
  g.connect_by_name( dc,           init         )
  g.connect_by_name( dc,           power        )
  g.connect_by_name( dc,           place        )
  g.connect_by_name( dc,           cts          )

  # --- Innovus Foundation Flow scripts go to all Innovus steps ---
  g.connect_by_name( iflow,        init         )
  g.connect_by_name( iflow,        power        )
  g.connect_by_name( iflow,        place        )
  g.connect_by_name( iflow,        cts          )
  g.connect_by_name( iflow,        postcts_hold )
  g.connect_by_name( iflow,        route        )
  g.connect_by_name( iflow,        postroute    )
  g.connect_by_name( iflow,        postroute_opt)
  g.connect_by_name( iflow,        signoff      )

  # --- Core place-and-route chain ---
  # This is the main pipeline: each step passes a checkpoint to the next
  g.connect_by_name( floorplan,    init         )  # floorplan.tcl
  g.connect_by_name( pin_placement,init         )  # pin-assignments.tcl
  g.connect_by_name( init,         power        )  # design.checkpoint
  g.connect_by_name( power,        place        )
  g.connect_by_name( place,        cts          )
  g.connect_by_name( cts,          postcts_hold )
  g.connect_by_name( postcts_hold, route        )
  g.connect_by_name( route,        postroute    )
  g.connect_by_name( postroute,    postroute_opt)
  g.connect_by_name( postroute_opt,signoff      )
  g.connect_by_name( signoff,      gdsmerge     )

  #-----------------------------------------------------------------------
  # Parameterize
  #-----------------------------------------------------------------------

  g.update_params( parameters )

  return g

if __name__ == '__main__':
  g = construct()
# g.plot()
