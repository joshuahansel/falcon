!include params_base.i
!include params_fracs.i

!include part_base.i

[GlobalParams]
  vpp_vars = 'p'
  create_flux_vpp = true
[]

[Components]
  # fracture 1
  [frac1_wall1]
    type = SolidWall1Phase
    input = 'frac1:in'
  []
  [frac1]
    type = FlowChannel1Phase
    position = '${x_frac_left} 0 ${z_frac1}'
    orientation = '1 0 0'
    length = ${L_frac}
    n_elems = ${n_elems_frac}
    A = ${A_frac1}
  []
  [frac1_wall2]
    type = SolidWall1Phase
    input = 'frac1:out'
  []
  [junction_inj_frac1]
    type = DiracSource1Phase
    flow_channel = frac1
    point = ${point_frac1_inj}
    mass_source_rate = mass_rate_inj1
    energy_source_rate = energy_rate_inj1
  []
  [junction_ext_frac1]
    type = DiracSource1Phase
    flow_channel = frac1
    point = ${point_frac1_ext}
    mass_source_rate = mass_rate_pro1
    energy_source_rate = energy_rate_pro1
  []

  # fracture 2
  [frac2_wall1]
    type = SolidWall1Phase
    input = 'frac2:in'
  []
  [frac2]
    type = FlowChannel1Phase
    position = '${x_frac_left} 0 ${z_frac2}'
    orientation = '1 0 0'
    length = ${L_frac}
    n_elems = ${n_elems_frac}
    A = ${A_frac2}
  []
  [frac2_wall2]
    type = SolidWall1Phase
    input = 'frac2:out'
  []
  [junction_inj_frac2]
    type = DiracSource1Phase
    flow_channel = frac2
    point = ${point_frac2_inj}
    mass_source_rate = mass_rate_inj2
    energy_source_rate = energy_rate_inj2
  []
  [junction_ext_frac2]
    type = DiracSource1Phase
    flow_channel = frac2
    point = ${point_frac2_ext}
    mass_source_rate = mass_rate_pro2
    energy_source_rate = energy_rate_pro2
  []
[]

[Functions]
  [mass_flux_frac1_fn]
    type = PiecewiseLinearFromVectorPostprocessor
    vectorpostprocessor_name = frac1:flux_vpp
    component = x
    argument_column = x
    value_column = mass_flux
  []
  [mass_flux_frac2_fn]
    type = PiecewiseLinearFromVectorPostprocessor
    vectorpostprocessor_name = frac2:flux_vpp
    component = x
    argument_column = x
    value_column = mass_flux
  []
[]

[Postprocessors]
  # fracture 1
  [p_inj1]
    type = PointValue
    point = ${point_frac1_inj}
    variable = p
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_pro1]
    type = PointValue
    point = ${point_frac1_ext}
    variable = p
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [T_inj1]
    type = PointValue
    point = ${point_frac1_inj}
    variable = T
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [T_pro1]
    type = PointValue
    point = ${point_frac1_ext}
    variable = T
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [mass_rate_inj1]
    type = Receiver
  []
  [mass_rate_pro1]
    type = Receiver
  []
  [energy_rate_inj1]
    type = Receiver
  []
  [energy_rate_pro1]
    type = Receiver
  []
  [p_frac1]
    type = PointValue
    variable = p
    point = '${x_middle} 0 ${z_frac1}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [mass_rate_frac1]
    type = FunctionValuePostprocessor
    function = mass_flux_frac1_fn
    point = '${x_middle} 0 ${z_frac1}'
    execute_on = 'INITIAL TIMESTEP_END'
  []

  # fracture 2
  [p_inj2]
    type = PointValue
    point = ${point_frac2_inj}
    variable = p
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_pro2]
    type = PointValue
    point = ${point_frac2_ext}
    variable = p
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [T_inj2]
    type = PointValue
    point = ${point_frac2_inj}
    variable = T
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [T_pro2]
    type = PointValue
    point = ${point_frac2_ext}
    variable = T
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [mass_rate_inj2]
    type = Receiver
  []
  [mass_rate_pro2]
    type = Receiver
  []
  [energy_rate_inj2]
    type = Receiver
  []
  [energy_rate_pro2]
    type = Receiver
  []
  [p_frac2]
    type = PointValue
    variable = p
    point = '${x_middle} 0 ${z_frac2}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [mass_rate_frac2]
    type = FunctionValuePostprocessor
    function = mass_flux_frac2_fn
    point = '${x_middle} 0 ${z_frac2}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

# [VectorPostprocessors]
#   [frac1:flux]
#     type = NumericalFlux3EqnInternalValues
#     block = 'frac1'
#     sort_by = x
#     numerical_flux = frac1:numerical_flux
#     A_linear = A_linear
#     execute_on = 'INITIAL TIMESTEP_END'
#   []
#   [frac2:flux]
#     type = NumericalFlux3EqnInternalValues
#     block = 'frac2'
#     sort_by = x
#     numerical_flux = frac2:numerical_flux
#     A_linear = A_linear
#     execute_on = 'INITIAL TIMESTEP_END'
#   []
# []

[Outputs]
  file_base = fracs
[]
