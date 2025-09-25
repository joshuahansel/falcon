!include params_base.i
!include params_wells.i

!include part_base.i
!include part_wells_base.i

[Components]
  # injection
  [inlet]
    type = InletMassFlowRateTemperature1Phase
    input = 'inj:in'
    m_dot = 0 # controlled
    T = ${T_inlet}
  []
  [inj]
    type = FlowChannel1Phase
    position = '${x_inj} 0 0'
    orientation = '0 0 -1'
    length = ${L_injext}
    n_elems = ${n_elems_injext}
    A = ${A_inj}
  []
  [inj_wall]
    type = SolidWall1Phase
    input = 'inj:out'
  []

  # extraction
  [outlet]
    type = Outlet1Phase
    input = 'ext:out'
    p = ${p_outlet}
  []
  [ext]
    type = FlowChannel1Phase
    position = '${x_ext} 0 ${z_wells_bottom}'
    orientation = '0 0 1'
    length = ${L_injext}
    n_elems = ${n_elems_injext}
    A = ${A_inj}
  []
  [ext_wall]
    type = SolidWall1Phase
    input = 'ext:in'
  []

  # junctions
  [junction_inj_frac1]
    type = DiracJunction1Phase
    flow_channel = inj
    point = ${point_frac1_inj}
    A_junction = ${A_inj_frac1}
    pressure = p_frac1_inj_sub
    temperature = T_frac1_inj_sub
  []
  [junction_ext_frac1]
    type = DiracJunction1Phase
    flow_channel = ext
    point = ${point_frac1_ext}
    A_junction = ${A_ext_frac1}
    pressure = p_frac1_ext_sub
    temperature = T_frac1_ext_sub
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
    from_postprocessor = mdot_frac1_inj
    to_postprocessor = mdot_frac1_inj_main
  []
  [mdot_frac1_ext_to_sub]
    type = MultiAppPostprocessorTransfer
    to_multi_app = fracs
    from_postprocessor = mdot_frac1_ext
    to_postprocessor = mdot_frac1_ext_main
  []
  [Edot_frac1_inj_to_sub]
    type = MultiAppPostprocessorTransfer
    to_multi_app = fracs
    from_postprocessor = Edot_frac1_inj
    to_postprocessor = Edot_frac1_inj_main
  []
  [Edot_frac1_ext_to_sub]
    type = MultiAppPostprocessorTransfer
    to_multi_app = fracs
    from_postprocessor = Edot_frac1_ext
    to_postprocessor = Edot_frac1_ext_main
  []
[]

[Postprocessors]
  [mdot_frac1_inj]
    type = DiracJunction1PhasePostprocessor
    dirac_junction_1phase_uo = junction_inj_frac1:uo
    equation = mass
    get_primary_side = false
    execute_on = 'TIMESTEP_END'
  []
  [mdot_frac1_ext]
    type = DiracJunction1PhasePostprocessor
    dirac_junction_1phase_uo = junction_ext_frac1:uo
    equation = mass
    get_primary_side = false
    execute_on = 'TIMESTEP_END'
  []
  [Edot_frac1_inj]
    type = DiracJunction1PhasePostprocessor
    dirac_junction_1phase_uo = junction_inj_frac1:uo
    equation = energy
    get_primary_side = false
    execute_on = 'TIMESTEP_END'
  []
  [Edot_frac1_ext]
    type = DiracJunction1PhasePostprocessor
    dirac_junction_1phase_uo = junction_ext_frac1:uo
    equation = energy
    get_primary_side = false
    execute_on = 'TIMESTEP_END'
  []

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
  [p_inj]
    type = ElementValueSampler
    variable = p
    block = 'inj'
    sort_by = z
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_ext]
    type = ElementValueSampler
    variable = p
    block = 'ext'
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
  [flux_inj]
    type = NumericalFlux3EqnInternalValues
    block = 'inj'
    sort_by = z
    numerical_flux = inj:numerical_flux
    A_linear = A_linear
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [flux_ext]
    type = NumericalFlux3EqnInternalValues
    block = 'ext'
    sort_by = z
    numerical_flux = ext:numerical_flux
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
