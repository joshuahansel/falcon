!include params_base.i
!include params_fracs.i

!include part_base.i

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
    A = ${A_frac}
  []
  [frac1_wall2]
    type = SolidWall1Phase
    input = 'frac1:out'
  []
  [junction_inj_frac1]
    type = DiracSource1Phase
    flow_channel = frac1
    point = ${point_frac1_inj}
    mass_source_rate = mdot_frac1_inj_main
    energy_source_rate = Edot_frac1_inj_main
  []
  [junction_ext_frac1]
    type = DiracSource1Phase
    flow_channel = frac1
    point = ${point_frac1_ext}
    mass_source_rate = mdot_frac1_ext_main
    energy_source_rate = Edot_frac1_ext_main
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
    A = ${A_frac}
  []
  [frac2_wall2]
    type = SolidWall1Phase
    input = 'frac2:out'
  []
  [junction_inj_frac2]
    type = DiracSource1Phase
    flow_channel = frac2
    point = ${point_frac2_inj}
    mass_source_rate = mdot_frac2_inj_main
    energy_source_rate = Edot_frac2_inj_main
  []
  [junction_ext_frac2]
    type = DiracSource1Phase
    flow_channel = frac2
    point = ${point_frac2_ext}
    mass_source_rate = mdot_frac2_ext_main
    energy_source_rate = Edot_frac2_ext_main
  []
[]

[Postprocessors]
  [p_frac1_inj]
    type = PointValue
    point = ${point_frac1_inj}
    variable = p
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_frac1_ext]
    type = PointValue
    point = ${point_frac1_ext}
    variable = p
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [T_frac1_inj]
    type = PointValue
    point = ${point_frac1_inj}
    variable = T
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [T_frac1_ext]
    type = PointValue
    point = ${point_frac1_ext}
    variable = T
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [mdot_frac1_inj_main]
    type = Receiver
  []
  [mdot_frac1_ext_main]
    type = Receiver
  []
  [Edot_frac1_inj_main]
    type = Receiver
  []
  [Edot_frac1_ext_main]
    type = Receiver
  []
[]

[VectorPostprocessors]
  [p_frac1]
    type = ElementValueSampler
    variable = p
    block = 'frac1'
    sort_by = x
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # [rhouA_frac1]
  #   type = ElementValueSampler
  #   variable = rhouA
  #   block = 'frac1'
  #   sort_by = x
  #   execute_on = 'INITIAL TIMESTEP_END'
  # []
  [flux_frac1]
    type = NumericalFlux3EqnInternalValues
    block = 'frac1'
    sort_by = z
    numerical_flux = frac1:numerical_flux
    A_linear = A_linear
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Outputs]
  file_base = fracs
[]
