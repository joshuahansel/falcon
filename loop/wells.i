!include params_base.i
!include params_wells.i

!include part_base.i

[Components]
  # [inlet]
  #   type = Outlet1Phase
  #   input = 'inj_pipe:in'
  #   p = 1e5
  # []
  [inlet]
    type = InletMassFlowRateTemperature1Phase
    input = 'inj_pipe:in'
    # m_dot = ${mdot_inlet}
    m_dot = 0
    T = ${T_inlet}
  []
  [inj_pipe]
    type = FlowChannel1Phase
    position = '${x_inj} 0 0'
    orientation = '0 0 -1'
    length = ${L_inj}
    n_elems = ${n_elems_inj}
    A = ${A_inj}
  []
  # [inj_wall]
  #   type = SolidWall1Phase
  #   input = 'inj_pipe:out'
  # []
  # [outlet]
  #   type = Outlet1Phase
  #   input = 'inj_pipe:out'
  #   p = ${p_outlet}
  # []

  # [junction_inj_frac1]
  #   type = DiracJunction1Phase
  #   flow_channel = inj_pipe
  #   point = ${point_frac1_inj}
  #   A_junction = ${A_inj_frac1}
  #   pressure = p_frac1_inj_sub
  #   temperature = T_frac1_inj_sub
  # []

  [inj_junc]
    type = JunctionOneToOne1Phase
    connections = 'inj_pipe:out frac:in'
  []
  [frac]
    type = FlowChannel1Phase
    position = '${x_inj} 0 -50'
    orientation = '1 0 0'
    length = 10
    n_elems = 10
    A = ${A_inj}
  []
  [ext_junc]
    type = JunctionOneToOne1Phase
    connections = 'frac:out ext_pipe:in'
  []

  [ext_pipe]
    type = FlowChannel1Phase
    position = '10 0 -50'
    orientation = '0 0 1'
    length = ${L_inj}
    n_elems = ${n_elems_inj}
    A = ${A_inj}
  []
  [outlet]
    type = Outlet1Phase
    input = 'ext_pipe:out'
    p = ${p_outlet}
  []
[]

# [Functions]
#   [mdot_fn]
#     type = TimeRampFunction
#     initial_value = 0
#     final_value = ${mdot_inlet}
#     ramp_duration = ${mdot_ramp_time}
#   []
# []

# [ChainControls]
#   [mdot_ctrl]

#   []
# []

# [MultiApps]
#   [fracs]
#     type = TransientMultiApp
#     app_type = FalconApp
#     input_files = fracs.i
#     execute_on = 'TIMESTEP_END'
#   []
# []

# [Transfers]
  # [p_frac1_inj_from_sub]
  #   type = MultiAppPostprocessorTransfer
  #   from_multi_app = fracs
  #   from_postprocessor = p_frac1_inj
  #   to_postprocessor = p_frac1_inj_sub
  #   reduction_type = average
  # []
  # [T_frac1_inj_from_sub]
  #   type = MultiAppPostprocessorTransfer
  #   from_multi_app = fracs
  #   from_postprocessor = T_frac1_inj
  #   to_postprocessor = T_frac1_inj_sub
  #   reduction_type = average
  # []

  # [mdot_frac1_inj_to_sub]
  #   type = MultiAppPostprocessorTransfer
  #   to_multi_app = fracs
  #   from_postprocessor = mdot_frac1_inj
  #   to_postprocessor = mdot_frac1_inj_main
  # []
  # [Edot_frac1_inj_to_sub]
  #   type = MultiAppPostprocessorTransfer
  #   to_multi_app = fracs
  #   from_postprocessor = Edot_frac1_inj
  #   to_postprocessor = Edot_frac1_inj_main
  # []
# []

[Postprocessors]
  # [mdot_frac1_inj]
  #   type = DiracJunction1PhasePostprocessor
  #   dirac_junction_1phase_uo = junction_inj_frac1:uo
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

  # [p_frac1_inj_sub]
  #   type = Receiver
  # []
  # [T_frac1_inj_sub]
  #   type = Receiver
  # []

  # [max_p_change]
  #   type = ADElementExtremeFunctorValue
  #   value_type = max
  #   block = ${wells_blocks}
  #   functor = p_change
  #   execute_on = 'MULTIAPP_FIXED_POINT_CONVERGENCE'
  # []
[]

[VectorPostprocessors]
  [p_inj]
    type = ElementValueSampler
    variable = p
    block = 'inj_pipe'
    sort_by = z
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_ext]
    type = ElementValueSampler
    variable = p
    block = 'ext_pipe'
    sort_by = z
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_frac]
    type = ElementValueSampler
    variable = p
    block = 'frac'
    sort_by = x
    execute_on = 'INITIAL TIMESTEP_END'
  []

  # [rhouA_inj]
  #   type = ElementValueSampler
  #   variable = rhouA
  #   block = 'inj_pipe'
  #   sort_by = z
  #   execute_on = 'INITIAL TIMESTEP_END'
  # []
  # [rhouA_ext]
  #   type = ElementValueSampler
  #   variable = rhouA
  #   block = 'ext_pipe'
  #   sort_by = z
  #   execute_on = 'INITIAL TIMESTEP_END'
  # []
  # [rhouA_frac]
  #   type = ElementValueSampler
  #   variable = rhouA
  #   block = 'frac'
  #   sort_by = x
  #   execute_on = 'INITIAL TIMESTEP_END'
  # []
  [rhouA_inj]
    type = NumericalFlux3EqnInternalValues
    block = 'inj_pipe'
    sort_by = z
    numerical_flux = inj_pipe:numerical_flux
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [rhouA_ext]
    type = NumericalFlux3EqnInternalValues
    block = 'ext_pipe'
    sort_by = z
    numerical_flux = ext_pipe:numerical_flux
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [rhouA_frac]
    type = NumericalFlux3EqnInternalValues
    block = 'frac'
    sort_by = x
    numerical_flux = frac:numerical_flux
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

[Outputs]
  file_base = wells
[]
