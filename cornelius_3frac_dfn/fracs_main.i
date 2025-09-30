!include fracs.i

[MultiApps]
  [wells]
    type = TransientMultiApp
    app_type = FalconApp
    input_files = wells.i
    max_procs_per_app = 1
    # sub_cycling = true
    # max_failures = 1000000
    execute_on = 'TIMESTEP_END'
  []
[]

[Physics]
  [CoupledInjectionProduction]
    [inj_prod]
      multi_app = wells
    []
  []
[]

[Executioner]
  fixed_point_max_its = 10
  fixed_point_abs_tol = 1e-6
[]
