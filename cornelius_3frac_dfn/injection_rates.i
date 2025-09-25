####### INJECTION RATES AND POSTPROCESSORS
# created by write_diracs_input.py

inj_ratio_stage_8_3 = 0.074
inj_ratio_stage_8_4 = 0.101
inj_ratio_stage_10 = 0.258

[Postprocessors]
  [mass_flux_src_stage_8_3]
    type = FunctionValuePostprocessor
    function = mass_flux_src
    scale_factor = ${inj_ratio_stage_8_3}
    execute_on = 'initial timestep_end'
  []
  [mass_flux_src_stage_8_4]
    type = FunctionValuePostprocessor
    function = mass_flux_src
    scale_factor = ${inj_ratio_stage_8_4}
    execute_on = 'initial timestep_end'
  []
  [mass_flux_src_stage_10]
    type = FunctionValuePostprocessor
    function = mass_flux_src
    scale_factor = ${inj_ratio_stage_10}
    execute_on = 'initial timestep_end'
  []
[]