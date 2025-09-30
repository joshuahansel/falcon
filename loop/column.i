# !include params_base.i
# !include params_fracs.i

# !include part_base.i

z_surface = 2800
z_end = 519.5491193579
length = ${fparse z_surface - z_end}

gravity_vector = '0 0 -9.80665'

radius = 0.09
A = ${fparse pi * radius^2}

[GlobalParams]
  gravity_vector = ${gravity_vector}

  fp = fp_water
  closures = simple_closures
  f = 0

  scaling_factor_1phase = '1 1 1e-5'

  initial_p = initial_p_fn
  initial_T = initial_T_fn
  initial_vel = 0

  rdg_slope_reconstruction = FULL
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
  [initial_T_fn]
    type = ParsedFunction
    expression = '426.67-0.0733333*(z-1150)'
  []
  [initial_p_fn]
    type = HydrostaticPressureFunction
    reference_pressure = ${units 1 atm -> Pa}
    reference_temperature = 305.670055
    reference_point = '0 0 ${z_surface}'
    fluid_properties = fp_water
    gravity_vector = ${gravity_vector}
  []
[]

[Components]
  [outlet]
    type = Outlet1Phase
    input = 'pipe:in'
    p = 657541
  []
  [pipe]
    type = FlowChannel1Phase
    position = '0 0 ${z_surface}'
    orientation = '0 0 -1'
    length = ${length}
    n_elems = 20
    A = ${A}
  []
  [wall]
    type = SolidWall1Phase
    input = 'pipe:out'
  []
[]

[Executioner]
  type = Transient
  scheme = 'bdf2'

  start_time = 0
  end_time = 100

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
[]
