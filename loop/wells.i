!include params_base.i
!include params_wells.i
!include params_fracs.i

L_injext_1 = ${fparse -z_frac1}
L_injext_2 = ${fparse -z_frac2 + z_frac1}
L_injext_3 = ${fparse L_injext + z_frac2}
n_elems_injext_1 = 20
n_elems_injext_2 = 10
n_elems_injext_3 = 20
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
  vpp_vars = 'p'
  create_flux_vpp = true
  multi_app = fracs
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
  [frac1_inj_junc]
    type = VolumeJunction1Phase
    connections = 'inj_1:out inj_2:in'
    position = ${point_frac1_inj}
    initial_vel_x = 0
    initial_vel_y = 0
    initial_vel_z = 0
    volume = ${fparse A_inj^(3/2)} # cube with A_inj side area
  []
  [frac1_inj_junc_flux]
    type = VolumeJunctionCoupledFlux1Phase
    A_coupled = ${A_inj_frac1}
    normal_from_junction = '1 0 0'
    volume_junction = frac1_inj_junc
    pp_suffix = frac1_inj
  []
  [inj_2]
    type = FlowChannel1Phase
    position = ${point_frac1_inj}
    orientation = '0 0 -1'
    length = ${L_injext_2}
    n_elems = ${n_elems_injext_2}
    A = ${A_inj}
  []
  [frac2_inj_junc]
    type = VolumeJunction1Phase
    connections = 'inj_2:out inj_3:in'
    position = ${point_frac2_inj}
    initial_vel_x = 0
    initial_vel_y = 0
    initial_vel_z = 0
    volume = ${fparse A_inj^(3/2)} # cube with A_inj side area
  []
  [frac2_inj_junc_flux]
    type = VolumeJunctionCoupledFlux1Phase
    A_coupled = ${A_inj_frac2}
    normal_from_junction = '1 0 0'
    volume_junction = frac2_inj_junc
    pp_suffix = frac2_inj
  []
  [inj_3]
    type = FlowChannel1Phase
    position = ${point_frac2_inj}
    orientation = '0 0 -1'
    length = ${L_injext_3}
    n_elems = ${n_elems_injext_3}
    A = ${A_inj}
  []
  [inj_wall]
    type = SolidWall1Phase
    input = 'inj_3:out'
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
    A = ${A_ext}
  []
  [frac1_ext_junc]
    type = VolumeJunction1Phase
    connections = 'ext_1:in ext_2:out'
    position = ${point_frac1_ext}
    initial_vel_x = 0
    initial_vel_y = 0
    initial_vel_z = 0
    volume = ${fparse A_ext^(3/2)} # cube with A_ext side area
  []
  [frac1_ext_junc_flux]
    type = VolumeJunctionCoupledFlux1Phase
    A_coupled = ${A_ext_frac1}
    normal_from_junction = '-1 0 0'
    volume_junction = frac1_ext_junc
    pp_suffix = frac1_ext
  []
  [ext_2]
    type = FlowChannel1Phase
    position = ${point_frac2_ext}
    orientation = '0 0 1'
    length = ${L_injext_2}
    n_elems = ${n_elems_injext_2}
    A = ${A_ext}
  []
  [frac2_ext_junc]
    type = VolumeJunction1Phase
    connections = 'ext_2:in ext_3:out'
    position = ${point_frac2_ext}
    initial_vel_x = 0
    initial_vel_y = 0
    initial_vel_z = 0
    volume = ${fparse A_ext^(3/2)} # cube with A_ext side area
  []
  [frac2_ext_junc_flux]
    type = VolumeJunctionCoupledFlux1Phase
    A_coupled = ${A_ext_frac2}
    normal_from_junction = '-1 0 0'
    volume_junction = frac2_ext_junc
    pp_suffix = frac2_ext
  []
  [ext_3]
    type = FlowChannel1Phase
    position = '${x_ext} 0 ${z_wells_bottom}'
    orientation = '0 0 1'
    length = ${L_injext_3}
    n_elems = ${n_elems_injext_3}
    A = ${A_ext}
  []
  [ext_wall]
    type = SolidWall1Phase
    input = 'ext_3:in'
  []
[]

[MultiApps]
  [fracs]
    type = TransientMultiApp
    app_type = FalconApp
    input_files = fracs.i
    execute_on = 'TIMESTEP_END'
  []
[]

[Postprocessors]
  [mass_flux_inlet]
    type = ADFlowBoundaryFlux1Phase
    boundary = inlet
    equation = mass
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [mass_flux_outlet]
    type = ADFlowBoundaryFlux1Phase
    boundary = outlet
    equation = mass
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_inlet]
    type = SideAverageValue
    boundary = inlet
    variable = p
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_outlet]
    type = SideAverageValue
    boundary = outlet
    variable = p
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # [max_p_change]
  #   type = ADElementExtremeFunctorValue
  #   value_type = max
  #   block = ${wells_blocks}
  #   functor = p_change
  #   execute_on = 'MULTIAPP_FIXED_POINT_CONVERGENCE'
  # []
[]

# [VectorPostprocessors]
#   [inj_1:flux]
#     type = NumericalFlux3EqnInternalValues
#     block = 'inj_1'
#     sort_by = z
#     numerical_flux = inj_1:numerical_flux
#     A_linear = A_linear
#     execute_on = 'INITIAL TIMESTEP_END'
#   []
#   [inj_2:flux]
#     type = NumericalFlux3EqnInternalValues
#     block = 'inj_2'
#     sort_by = z
#     numerical_flux = inj_2:numerical_flux
#     A_linear = A_linear
#     execute_on = 'INITIAL TIMESTEP_END'
#   []
#   [inj_3:flux]
#     type = NumericalFlux3EqnInternalValues
#     block = 'inj_3'
#     sort_by = z
#     numerical_flux = inj_3:numerical_flux
#     A_linear = A_linear
#     execute_on = 'INITIAL TIMESTEP_END'
#   []
#   [ext_1:flux]
#     type = NumericalFlux3EqnInternalValues
#     block = 'ext_1'
#     sort_by = z
#     numerical_flux = ext_1:numerical_flux
#     A_linear = A_linear
#     execute_on = 'INITIAL TIMESTEP_END'
#   []
#   [ext_2:flux]
#     type = NumericalFlux3EqnInternalValues
#     block = 'ext_2'
#     sort_by = z
#     numerical_flux = ext_2:numerical_flux
#     A_linear = A_linear
#     execute_on = 'INITIAL TIMESTEP_END'
#   []
#   [ext_3:flux]
#     type = NumericalFlux3EqnInternalValues
#     block = 'ext_3'
#     sort_by = z
#     numerical_flux = ext_3:numerical_flux
#     A_linear = A_linear
#     execute_on = 'INITIAL TIMESTEP_END'
#   []
# []

# [FunctorMaterials]
#   [p_change_fmat]
#     type = FunctorChangeFunctorMaterial
#     functor = p
#     change_over = fixed_point
#     take_absolute_value = true
#     prop_name = p_change
#   []
# []

# [Convergence]
#   [fp_conv]
#     type = PostprocessorConvergence
#     postprocessor = max_p_change
#     tolerance = ${max_p_change_tol}
#     max_iterations = 10
#   []
# []

# [Executioner]
#   multiapp_fixed_point_convergence = fp_conv
# []

[Executioner]
  fixed_point_max_its = 10
  fixed_point_abs_tol = 1e-6
[]

[Outputs]
  file_base = wells
[]
