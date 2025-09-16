[GlobalParams]
  # gravity_vector = '0 0 -9.8'
  gravity_vector = '-9.8 0 0'

  fp = fp_water
  closures = simple_closures
  f = 0

  scaling_factor_1phase = '1 1 1e-5'

  initial_p = initial_p_fn
  initial_T = ${T_inlet}
  initial_vel = 0
[]

[FluidProperties]
  [fp_water]
    type = IAPWS95LiquidFluidProperties
  []
[]

[Closures]
  [simple_closures]
    type = Closures1PhaseSimple
  []
[]

[Functions]
  [initial_p_fn]
    type = HydrostaticPressureFunction
    reference_pressure = ${p_outlet}
    reference_temperature = ${T_inlet}
    reference_point = ${p_reference_point}
    fluid_properties = fp_water
  []
[]

[Preconditioning]
  [pc]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  scheme = 'bdf2'

  start_time = 0
  end_time = 1000

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0
    optimal_iterations = 5
    iteration_window = 0
    growth_factor = 1.1
    cutback_factor = 0.8
  []
  dtmin = 1e-4

  steady_state_detection = true

  solve_type = NEWTON
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-6
  nl_max_its = 30

  l_tol = 1e-3
  l_max_its = 10
[]

[Outputs]
  exodus = true
  [xml]
    type = XMLOutput
    execute_vector_postprocessors_on = 'INITIAL TIMESTEP_END'
  []
[]
