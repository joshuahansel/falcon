!include params_base.i
!include params_mdot.i

!include part_base.i
!include part_mdot.i
!include part_ics.i

# Units K,m,Pa,Kg,s
# Cold water injection into one side of the fracture network, and production from the other side
# These are initial fracture properties
# fracture permeability = roughness/12 * (aperature_o)^3 = 12e-3/12*(1e-4)^3 = 1e-15 m^-2
# fracture porosity = aperature ~1.5e-4m  Cornelius value matching 10% flow 5m mesh
frac_aperature = 1.5e-4
frac_roughness = 10e-3 #was 12e-3
# job_id = 0
# These should just be pass through, so high permeability, porosity ~1
inj_perm = 1.0e-9 #these are from the fracture volumetric fracture properties
inj_poro = 0.9
matrix_perm = 5.0e-17
matrix_poro = 2e-4 #2.0e-4 gives 90% recover and 2.5e-3 gives 50% mass recovery after 30 days

biot_coeff = 0.47

initial_dt = 100
dt_max = 50000

injection_temp = 323.15

###########################################################
# Fracture materials
!include fracture_materials_nonlinear.i

# injection rates and postprocessors
# !include injection_rates.i

# includding injection & production diracs
# !include injection_pressure_diracs.i
# !include injection_temperature_diracs.i

# includding injection & production pp
# !include injection_pressure_pp.i
# !include injection_temperature_pp.i
# !include production_pressure_pp.i
# !include production_temperature_pp.i
###########################################################

[PorousFlowFullySaturated]
  coupling_type = ThermoHydro
  porepressure = porepressure
  temperature = temperature
  fp = fp_water
  pressure_unit = Pa
  stabilization = full
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = '3frac_Fractures_Local_20m_marked.e'
  []
  construct_node_list_from_side_list = false
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = ${gravity_vector}
[]

[Variables]
  [porepressure]
  []
  [temperature]
    scaling = 1e-6
  []
[]

[AuxVariables]
  # [Pdiff]
  #   initial_condition = 0
  # []
  # [Tdiff]
  #   initial_condition = 0
  # []
  [density]
    order = CONSTANT
    family = MONOMIAL
  []
  [viscosity]
    order = CONSTANT
    family = MONOMIAL
  []
  [initial_p]
  []
  [permeability]
    order = CONSTANT
    family = MONOMIAL
  []
  [porosity]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  # [Pdiff]
  #   type = ParsedAux
  #   use_xyzt = true
  #   variable = Pdiff
  #   coupled_variables = 'porepressure'
  #   expression = 'porepressure-(1.6025e7-${water_weight}*(z-1150))'
  #   execute_on = TIMESTEP_END
  # []
  # [Tdiff]
  #   type = ParsedAux
  #   use_xyzt = true
  #   variable = Tdiff
  #   coupled_variables = 'temperature'
  #   expression = 'temperature-(426.67-0.0733333*(z-1150))'
  #   execute_on = TIMESTEP_END
  # []
  [density]
    type = MaterialRealAux
    variable = density
    property = PorousFlow_fluid_phase_density_qp0
    execute_on = TIMESTEP_END
  []
  [viscosity]
    type = MaterialRealAux
    variable = viscosity
    property = PorousFlow_viscosity_qp0
    execute_on = TIMESTEP_END
  []
  [porosity]
    type = MaterialRealAux
    variable = porosity
    property = PorousFlow_porosity_qp
    execute_on = TIMESTEP_END
  []
  [permeability]
    type = MaterialRealTensorValueAux
    variable = permeability
    property = PorousFlow_permeability_qp
    execute_on = TIMESTEP_END
  []
[]

[Functions]
  # NOTE: because this is used in BCs, it should be reasonably physically correct,
  # otherwise the BCs will be withdrawing or injecting heat-energy inappropriately
  # [insitu_T]
  #   type = ParsedFunction
  #   expression = '426.67-0.0733333*(z-1150)'
  # []
  # [insitu_pp]
  #   type = ParsedFunction
  #   expression = '1.6025e7-${water_weight}*(z-1150)'
  # []
  # These are linevalue samplers from the equilibration simulation
  # [insitu_T]
  #   type = PiecewiseLinear
  #   axis = z
  #   data_file = "equilibrate_output/equilibrate_none_20m_temperature_corner_0008.csv"
  #   format = columns
  #   xy_in_file_only = false
  #   x_title = "z"
  #   y_title = "temperature"
  # []
  # [insitu_pp]
  #   type = PiecewiseLinear
  #   axis = z
  #   data_file = "equilibrate_output/equilibrate_none_20m_porepressure_corner_0008.csv"
  #   format = columns
  #   xy_in_file_only = false
  #   x_title = "z"
  #   y_title = "porepressure"
  # []
[]

[BCs]
  # PorousFlowOutflowBC for porepressure above in switch w/ wo/ tracer because it changes
  [porepressure]
    type = FunctionDirichletBC
    variable = porepressure
    boundary = 'zmax'
    function = initial_p_fn
    save_in = porepressure_out_zmax
  []
  [temperature]
    type = FunctionDirichletBC
    variable = temperature
    boundary = 'zmax zmin'
    function = insitu_T
  []
  [temperature_outflow]
    type = PorousFlowOutflowBC
    boundary = 'xmin xmax ymin ymax'
    flux_type = heat
    variable = temperature
    save_in = temperature_outflow
  []
  [porepressure_outflow]
    type = PorousFlowOutflowBC
    boundary = 'xmin xmax ymin ymax'
    flux_type = fluid
    variable = porepressure
    mass_fraction_component = 0
    save_in = porepressure_outflow
  []
[]

[AuxVariables]
  [porepressure_outflow]
  []
  [porepressure_out_zmax]
  []
  [temperature_outflow]
  []
[]

[Postprocessors]
  [porepressure_kg_per_s]
    type = NodalSum
    boundary = 'xmin xmax ymin ymax'
    variable = porepressure_outflow
  []
  [porepressure_zmax_kg_per_s]
    type = NodalSum
    boundary = 'zmax'
    variable = porepressure_out_zmax
  []
  [temperature_J_per_s]
    type = NodalSum
    boundary = 'xmin xmax ymin ymax'
    variable = temperature_outflow
  []
[]

[ICs]
  [porepressure]
    type = FunctionIC
    variable = porepressure
    function = initial_p_fn
  []
  [temperature]
    type = FunctionIC
    variable = temperature
    function = insitu_T
  []
  [initial_p_ic]
    type = FunctionIC
    variable = initial_p
    function = initial_p_fn
  []
[]

# Media properties:
# - porosity
# - permeability
# - internal energy?
# - thermal conductivity
# - Biot modulus
[Materials]
  [biot_modulus]
    type = PorousFlowConstantBiotModulus
    biot_coefficient = ${biot_coeff}
    solid_bulk_compliance = 2e-7
    fluid_bulk_modulus = 1e7
  []

  [porosity_inj_prod_volume]
    type = PorousFlowPorosityConst
    porosity = ${inj_poro}
    block = '2000 3000'
  []
  [permeability_inj_prod_volume]
    type = PorousFlowPermeabilityConst
    block = '2000 3000'
    permeability = '${inj_perm} 0 0 0 ${inj_perm} 0 0 0 ${inj_perm}'
  []
  [rock_internal_energy_inj_prod_volume]
    type = PorousFlowMatrixInternalEnergy
    density = 2500.0
    specific_heat_capacity = 100.0
    block = '2000 3000'
  []
  [thermal_conductivity_inj_prod_volume]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '3 0 0 0 3 0 0 0 3'
    block = '2000 3000'
  []

  [porosity_matrix]
    type = PorousFlowPorosity
    porosity_zero = ${matrix_poro}
    block = '1000'
  []
  # [porosity_matrix]
  #   type = PorousFlowPorosity
  #   porosity_zero = ${matrix_poro}
  #   fluid = true
  #   solid_bulk = 5.4e10
  #   block = '1000'
  # []
  [permeability_matrix]
    type = PorousFlowPermeabilityConst
    permeability = '${matrix_perm} 0 0  0 ${matrix_perm} 0  0 0 ${matrix_perm}'
    block = '1000'
  []
  [rock_internal_energy_matrix]
    type = PorousFlowMatrixInternalEnergy
    density = 2750.0
    specific_heat_capacity = 790.0
    block = '1000'
  []
  [thermal_conductivity_matrix]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '3.05 0 0 0 3.05 0 0 0 3.05'
    block = '1000'
  []
[]

##########################################################

[Postprocessors]
  [inject_T]
    type = Receiver
    default = ${injection_temp}
  []
  [param_frac_aperature]
    type = Receiver
    default = '${frac_aperature}'
  []
  [param_frac_roughness]
    type = Receiver
    default = ${frac_roughness}
  []
  [param_matrix_perm]
    type = Receiver
    default = ${matrix_perm}
  []
  [param_matrix_poro]
    type = Receiver
    default = ${matrix_poro}
  []
  [param_biot_coeff]
    type = Receiver
    default = ${biot_coeff}
  []
  [injection_rate_kg_s]
    type = FunctionValuePostprocessor
    function = inlet_mdot_fn
    execute_on = timestep_end
  []
  [a2_nl_it]
    type = NumNonlinearIterations
  []
  [a1_dt]
    type = TimestepSize
  []
  [a0_wall_time]
    type = PerfGraphData
    section_name = "Root"
    data_type = total
  []
  # [p_well_58_bottom]
  #   type = PointValue
  #   variable = Pdiff
  #   point = '38.51767602 53.58355641 540.3684522'
  # []
  # [t_well_58_bottom]
  #   type = PointValue
  #   variable = Tdiff
  #   point = '38.51767602 53.58355641 540.3684522'
  # []
[]


###########################################################
[Preconditioning]
  active = asm_ilu
  # active = preferred
  [hypre]
    type = SMP
    full = true
    #petsc_options_iname = '-pc_type -pc_hypre_type -pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_agg_nl -pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_max_levels -pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_interp_type -pc_hypre_boomeramg_truncfactor'
    #petsc_options_value = 'hypre    boomeramg       0.7                                  4                          5                                 25                             HMIS                             ext+i                           0.3'
    petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix'
    petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
    petsc_options_value = 'hypre    boomeramg      31                 0.7'
  []
  [asm_ilu] #uses less memory
    type = SMP
    full = true
    petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix'
    petsc_options_iname = '-ksp_type -ksp_grmres_restart -pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
    petsc_options_value = 'gmres 30 asm ilu NONZERO 2'
  []
  [asm_lu] #uses less memory
    type = SMP
    full = true
    petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix'
    petsc_options_iname = '-ksp_type -ksp_grmres_restart -pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
    petsc_options_value = 'gmres 30 asm lu NONZERO 2'
  []
  [superlu]
    type = SMP
    full = true
    petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix'
    petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package'
    petsc_options_value = 'gmres lu superlu_dist'
  []
  [preferred]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
[]

[Executioner]
  type = Transient

  start_time = ${initial_time}
  end_time = ${final_time}

  dtmin = 1e-3
  dtmax = ${dt_max}
  steady_state_detection = true
  steady_state_start_time = ${injection_ramp_duration}
  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 6
    iteration_window = 0
    growth_factor = 1.2
    cutback_factor = 0.9
    cutback_factor_at_failure = 0.5
    linear_iteration_ratio = 1000
    dt = ${initial_dt}
    # force_step_every_function_point = true
    # post_function_sync_dt = 100
    # timestep_limiting_function = inlet_mdot_fn
  []

  solve_type = NEWTON
  l_tol = 1e-4
  l_max_its = 200
  nl_max_its = 20
  nl_abs_tol = 1e-5
  # nl_abs_tol = 1e-6
  nl_rel_tol = 1e-5 #rkp
  error_on_dtmin = false
  automatic_scaling = true

  # compute_scaling_once = false

  line_search = none
  #predictor helps but the nl_rel_tol is hard to satisfy.
  # [Predictor]
  #   type = SimplePredictor
  #   scale = 1.0
  # []
[]

##############################################################

[Outputs]
  csv = true
  print_linear_residuals = false
  # [checkpoint]
  #   type = Checkpoint
  #   num_files = 2
  #   wall_time_interval = 72000 # seconds
  # []
  exodus = true
  # [nem]
  #   type = Nemesis
  #   sync_times = '0 86400 172800 259200 864000 1728000 2592000 8640000 15768000'
  #   sync_only = true
  # []
  # [nem]
  #   execute_on = FINAL
  #   type = Nemesis
  #   hide = 'porepressure temperature insitu_pp viscosity density'
  # []
  [console]
    type = Console
    execute_postprocessors_on = 'NONE'
  []
[]
