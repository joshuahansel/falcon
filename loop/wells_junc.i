!include params_base.i
!include params_wells.i
!include params_fracs.i

L_injext_1 = ${fparse -z_frac1}
L_injext_2 = ${fparse L_injext + z_frac1}
n_elems_injext_1 = 20
n_elems_injext_2 = 30
L_frac_1 = ${fparse x_inj - x_frac_left}
L_frac_2 = ${fparse x_ext - x_inj}
L_frac_3 = ${fparse L_frac - L_frac_1 - L_frac_2}
n_elems_frac_1 = 10
n_elems_frac_2 = 30
n_elems_frac_3 = 10

!include part_base.i
!include part_wells_base.i

[GlobalParams]
  scaling_factor_rhoEV = 1e-5
[]

[Components]
  # injection
  [inlet]
    type = InletMassFlowRateTemperature1Phase
    input = 'inj_1:in'
    m_dot = 0 # controlled
    T = ${T_inlet}
  []
  [inj_1]
    type = FlowChannel1Phase
    position = '${x_inj} 0 0'
    orientation = '0 0 -1'
    length = ${L_injext_1}
    n_elems = ${n_elems_injext_1}
    A = ${A_inj}
  []
  [inj_junc]
    type = VolumeJunction1Phase
    connections = 'inj_1:out inj_2:in frac1_1:out frac1_2:in'
    position = ${point_frac1_inj}
    initial_vel_x = 0
    initial_vel_y = 0
    initial_vel_z = 0
    volume = ${fparse A_inj^(3/2)} # cube with A_inj side area
  []
  [inj_2]
    type = FlowChannel1Phase
    position = ${point_frac1_inj}
    orientation = '0 0 -1'
    length = ${L_injext_2}
    n_elems = ${n_elems_injext_2}
    A = ${A_inj}
  []
  [inj_wall]
    type = SolidWall1Phase
    input = 'inj_2:out'
  []

  # fracture 1
  [frac1_wall1]
    type = SolidWall1Phase
    input = 'frac1_1:in'
  []
  [frac1_1]
    type = FlowChannel1Phase
    position = '${x_frac_left} 0 ${z_frac1}'
    orientation = '1 0 0'
    length = ${L_frac_1}
    n_elems = ${n_elems_frac_1}
    A = ${A_frac}
  []
  [frac1_2]
    type = FlowChannel1Phase
    position = ${point_frac1_inj}
    orientation = '1 0 0'
    length = ${L_frac_2}
    n_elems = ${n_elems_frac_2}
    A = ${A_frac}
  []
  [frac1_3]
    type = FlowChannel1Phase
    position = ${point_frac1_ext}
    orientation = '1 0 0'
    length = ${L_frac_3}
    n_elems = ${n_elems_frac_3}
    A = ${A_frac}
  []
  [frac1_wall2]
    type = SolidWall1Phase
    input = 'frac1_3:out'
  []

  # extraction
  [outlet]
    type = Outlet1Phase
    input = 'ext_1:out'
    p = ${p_outlet}
  []
  [ext_1]
    type = FlowChannel1Phase
    position = ${point_frac1_ext}
    orientation = '0 0 1'
    length = ${L_injext_1}
    n_elems = ${n_elems_injext_1}
    A = ${A_inj}
  []
  [ext_junc]
    type = VolumeJunction1Phase
    connections = 'ext_1:in ext_2:out frac1_2:out frac1_3:in'
    position = ${point_frac1_ext}
    initial_vel_x = 0
    initial_vel_y = 0
    initial_vel_z = 0
    volume = ${fparse A_inj^(3/2)} # cube with A_inj side area
  []
  [ext_2]
    type = FlowChannel1Phase
    position = '${x_ext} 0 ${z_wells_bottom}'
    orientation = '0 0 1'
    length = ${L_injext_2}
    n_elems = ${n_elems_injext_2}
    A = ${A_inj}
  []
  [ext_wall]
    type = SolidWall1Phase
    input = 'ext_2:in'
  []
[]

[VectorPostprocessors]
  [p_inj_1]
    type = ElementValueSampler
    variable = p
    block = 'inj_1'
    sort_by = z
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_inj_2]
    type = ElementValueSampler
    variable = p
    block = 'inj_2'
    sort_by = z
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_frac1_1]
    type = ElementValueSampler
    variable = p
    block = 'frac1_1'
    sort_by = x
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_frac1_2]
    type = ElementValueSampler
    variable = p
    block = 'frac1_2'
    sort_by = x
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_frac1_3]
    type = ElementValueSampler
    variable = p
    block = 'frac1_3'
    sort_by = x
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_ext_1]
    type = ElementValueSampler
    variable = p
    block = 'ext_1'
    sort_by = z
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_ext_2]
    type = ElementValueSampler
    variable = p
    block = 'ext_2'
    sort_by = z
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # [rhouA_inj]
  #   type = ElementValueSampler
  #   variable = rhouA
  #   block = 'inj_pipe'
  #   sort_by = z
  #   execute_on = 'INITIAL TIMESTEP_END'
  # []
  [flux_inj_1]
    type = NumericalFlux3EqnInternalValues
    block = 'inj_1'
    sort_by = z
    numerical_flux = inj_1:numerical_flux
    A_linear = A_linear
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [flux_inj_2]
    type = NumericalFlux3EqnInternalValues
    block = 'inj_2'
    sort_by = z
    numerical_flux = inj_2:numerical_flux
    A_linear = A_linear
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [flux_frac1_1]
    type = NumericalFlux3EqnInternalValues
    block = 'frac1_1'
    sort_by = z
    numerical_flux = frac1_1:numerical_flux
    A_linear = A_linear
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [flux_frac1_2]
    type = NumericalFlux3EqnInternalValues
    block = 'frac1_2'
    sort_by = z
    numerical_flux = frac1_2:numerical_flux
    A_linear = A_linear
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [flux_frac1_3]
    type = NumericalFlux3EqnInternalValues
    block = 'frac1_3'
    sort_by = z
    numerical_flux = frac1_3:numerical_flux
    A_linear = A_linear
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [flux_ext_1]
    type = NumericalFlux3EqnInternalValues
    block = 'ext_1'
    sort_by = z
    numerical_flux = ext_1:numerical_flux
    A_linear = A_linear
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [flux_ext_2]
    type = NumericalFlux3EqnInternalValues
    block = 'ext_2'
    sort_by = z
    numerical_flux = ext_2:numerical_flux
    A_linear = A_linear
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Outputs]
  file_base = wells_junc
[]
