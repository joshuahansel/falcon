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
    A = ${A_injext}
  []
  [inj_junc]
    type = VolumeJunction1Phase
    connections = 'inj_1:out inj_2:in'
    position = ${point_frac1_inj}
    initial_vel_x = 0
    initial_vel_y = 0
    initial_vel_z = 0
    volume = ${fparse A_injext^(3/2)} # cube with A_injext side area
  []
  [inj_2]
    type = FlowChannel1Phase
    position = ${point_frac1_inj}
    orientation = '0 0 -1'
    length = ${L_injext_2}
    n_elems = ${n_elems_injext_2}
    A = ${A_injext}
  []
  [inj_wall]
    type = SolidWall1Phase
    input = 'inj_2:out'
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
    A = ${A_injext}
  []
  [ext_junc]
    type = VolumeJunction1Phase
    connections = 'ext_1:in ext_2:out'
    position = ${point_frac1_ext}
    initial_vel_x = 0
    initial_vel_y = 0
    initial_vel_z = 0
    volume = ${fparse A_injext^(3/2)} # cube with A_injext side area
  []
  [ext_2]
    type = FlowChannel1Phase
    position = '${x_ext} 0 ${z_wells_bottom}'
    orientation = '0 0 1'
    length = ${L_injext_2}
    n_elems = ${n_elems_injext_2}
    A = ${A_injext}
  []
  [ext_wall]
    type = SolidWall1Phase
    input = 'ext_2:in'
  []

  # junctions
  [inj_junc_flux]
    type = VolumeJunctionCoupledFlux1Phase
    A_coupled = ${A_inj_frac1}
    pressure = p_frac1_inj_fn
    temperature = T_frac1_inj_fn
    normal_from_junction = '1 0 0'
    volume_junction = inj_junc
  []
  [ext_junc_flux]
    type = VolumeJunctionCoupledFlux1Phase
    A_coupled = ${A_ext_frac1}
    pressure = p_frac1_ext_fn
    temperature = T_frac1_ext_fn
    normal_from_junction = '-1 0 0'
    volume_junction = ext_junc
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

[Transfers]
  [p_frac1_inj_from_sub]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracs
    from_postprocessor = p_frac1_inj
    to_postprocessor = p_frac1_inj_sub
    reduction_type = average
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_frac1_ext_from_sub]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracs
    from_postprocessor = p_frac1_ext
    to_postprocessor = p_frac1_ext_sub
    reduction_type = average
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [T_frac1_inj_from_sub]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracs
    from_postprocessor = T_frac1_inj
    to_postprocessor = T_frac1_inj_sub
    reduction_type = average
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [T_frac1_ext_from_sub]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracs
    from_postprocessor = T_frac1_ext
    to_postprocessor = T_frac1_ext_sub
    reduction_type = average
    execute_on = 'INITIAL TIMESTEP_END'
  []

  [mdot_frac1_inj_to_sub]
    type = MultiAppPostprocessorTransfer
    to_multi_app = fracs
    from_postprocessor = inj_junc_flux:mass_flux
    to_postprocessor = mdot_frac1_inj_main
  []
  [mdot_frac1_ext_to_sub]
    type = MultiAppPostprocessorTransfer
    to_multi_app = fracs
    from_postprocessor = ext_junc_flux:mass_flux
    to_postprocessor = mdot_frac1_ext_main
  []
  [Edot_frac1_inj_to_sub]
    type = MultiAppPostprocessorTransfer
    to_multi_app = fracs
    from_postprocessor = inj_junc_flux:energy_flux
    to_postprocessor = Edot_frac1_inj_main
  []
  [Edot_frac1_ext_to_sub]
    type = MultiAppPostprocessorTransfer
    to_multi_app = fracs
    from_postprocessor = ext_junc_flux:energy_flux
    to_postprocessor = Edot_frac1_ext_main
  []
[]

[Functions]
  [p_frac1_inj_fn]
    type = ParsedFunction
    expression = 'p'
    symbol_names = 'p'
    symbol_values = 'p_frac1_inj_sub'
  []
  [p_frac1_ext_fn]
    type = ParsedFunction
    expression = 'p'
    symbol_names = 'p'
    symbol_values = 'p_frac1_ext_sub'
  []
  [T_frac1_inj_fn]
    type = ParsedFunction
    expression = 'T'
    symbol_names = 'T'
    symbol_values = 'T_frac1_inj_sub'
  []
  [T_frac1_ext_fn]
    type = ParsedFunction
    expression = 'T'
    symbol_names = 'T'
    symbol_values = 'T_frac1_ext_sub'
  []
[]

[Postprocessors]
  # [mdot_frac1_inj]
  #   type = DiracJunction1PhasePostprocessor
  #   dirac_junction_1phase_uo = junction_inj_frac1:uo
  #   equation = mass
  #   get_primary_side = false
  #   execute_on = 'TIMESTEP_END'
  # []
  # [mdot_frac1_ext]
  #   type = DiracJunction1PhasePostprocessor
  #   dirac_junction_1phase_uo = junction_ext_frac1:uo
  #   equation = mass
  #   get_primary_side = false
  #   execute_on = 'TIMESTEP_END'
  # []
  # [Edot_frac1_inj]
  #   type = DiracJunction1PhasePostprocessor
  #   dirac_junction_1phase_uo = junction_inj_frac1:uo
  #   equation = energy
  #   get_primary_side = false
  #   execute_on = 'TIMESTEP_END'
  # []
  # [Edot_frac1_ext]
  #   type = DiracJunction1PhasePostprocessor
  #   dirac_junction_1phase_uo = junction_ext_frac1:uo
  #   equation = energy
  #   get_primary_side = false
  #   execute_on = 'TIMESTEP_END'
  # []

  [p_frac1_inj_sub]
    type = Receiver
  []
  [p_frac1_ext_sub]
    type = Receiver
  []
  [T_frac1_inj_sub]
    type = Receiver
  []
  [T_frac1_ext_sub]
    type = Receiver
  []

  # [max_p_change]
  #   type = ADElementExtremeFunctorValue
  #   value_type = max
  #   block = ${wells_blocks}
  #   functor = p_change
  #   execute_on = 'MULTIAPP_FIXED_POINT_CONVERGENCE'
  # []
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
  #   block = 'inj'
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
