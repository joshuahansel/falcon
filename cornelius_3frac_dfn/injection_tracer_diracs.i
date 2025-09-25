# created by write_diracs_input.py
[DiracKernels]
  [source_8_3_tracer]
    type = PorousFlowSquarePulsePointSource
    variable = C
    mass_flux = ${fparse inj_ratio_stage_8_3*tracer_flux_src}
    point = '53.8865543998 225.4920635023 373.2999856190'
    start_time = ${tracer_start_time}
    end_time = ${tracer_end_time}
    point_not_found_behavior = WARNING
  []
  [source_8_4_tracer]
    type = PorousFlowSquarePulsePointSource
    variable = C
    mass_flux = ${fparse inj_ratio_stage_8_4*tracer_flux_src}
    point = '-13.3484490202 218.2456800420 404.5581304535'
    start_time = ${tracer_start_time}
    end_time = ${tracer_end_time}
    point_not_found_behavior = WARNING
  []
  [source_10_tracer]
    type = PorousFlowSquarePulsePointSource
    variable = C
    mass_flux = ${fparse inj_ratio_stage_10*tracer_flux_src}
    point = '-45.5934589398 214.7704112881 419.5491193579'
    start_time = ${tracer_start_time}
    end_time = ${tracer_end_time}
    point_not_found_behavior = WARNING
  []
[]
