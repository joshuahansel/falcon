!include fracs_base.i

production_delay = 1 #time to start peaceman, should be 1e5s

inj1_mass_ratio = ${fparse inj1_mass_ratio_unnormalized / total_mass_ratio}
inj2_mass_ratio = ${fparse inj2_mass_ratio_unnormalized / total_mass_ratio}
inj3_mass_ratio = ${fparse inj3_mass_ratio_unnormalized / total_mass_ratio}
inj_mass_ratios = '${inj1_mass_ratio} ${inj2_mass_ratio} ${inj3_mass_ratio}'

##########################################################
[Physics]
  [InjectionProduction]
    [inj_prod]
      injection_points = '${inj_point1} ${inj_point2} ${inj_point3}'
      production_points = '${pro_point1} ${pro_point2} ${pro_point3}'
      injection_mass_ratios = ${inj_mass_ratios}
      injection_mass_flow_rate = inlet_mdot_fn
      injection_temperature = inject_T
      fluid_properties = fp_water
    []
  []
[]
##########################################################
# PEACEMANS
[Functions]
  [insitu_pp_borehole]
    type = ParsedFunction
    symbol_names = 'back_pressure_Pa'
    symbol_values = '3.44738e6' #500psi back-pressure
    expression = '1.6025e7-${water_weight}*(z-1150)+back_pressure_Pa'
  []
  #delaying production for initial heaviside injection
  [character_function]
    type = PiecewiseLinear
    xy_data = "0 0
    ${fparse production_delay} 0
    ${fparse production_delay + 14500} 1"
  []
[]

[UserObjects]
  [borehole_fluid_outflow_mass]
    type = PorousFlowSumQuantity
  []
  [borehole_prod_temperature]
    type = PorousFlowSumQuantity
  []
[]

[DiracKernels]
  [withdraw_fluid]
    type = PorousFlowPeacemanBorehole
    variable = porepressure
    bottom_p_or_t = insitu_pp_borehole
    SumQuantityUO = borehole_fluid_outflow_mass
    point_file = peaceman_production_points.txt
    function_of = pressure
    fluid_phase = 0
    unit_weight = '0 0 -${water_weight}'
    use_mobility = true
    character = character_function
    point_not_found_behavior = WARNING
  []
  [bh_energy_flow]
    type = PorousFlowPeacemanBorehole
    variable = temperature
    bottom_p_or_t = insitu_pp_borehole
    SumQuantityUO = borehole_prod_temperature
    point_file = peaceman_production_points.txt
    function_of = pressure
    fluid_phase = 0
    unit_weight = '0 0 -${water_weight}'
    use_mobility = true
    use_enthalpy = true
    character = character_function
    point_not_found_behavior = WARNING
  []
[]

[Postprocessors]
  [fluid_report]
    type = PorousFlowPlotQuantity
    uo = borehole_fluid_outflow_mass
  []
  [energy_prod]
    type = PorousFlowPlotQuantity
    uo = borehole_prod_temperature
  []
[]
##############################################################
[Outputs]
  file_base = 'outputs/fracs_standalone'
[]
