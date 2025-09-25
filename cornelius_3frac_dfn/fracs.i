# Units K,m,Pa,Kg,s
# Cold water injection into one side of the fracture network, and production from the other side
# These are initial fracture properties
# fracture permeability = roughness/12 * (aperature_o)^3 = 12e-3/12*(1e-4)^3 = 1e-15 m^-2
# fracture porosity = aperature ~1.5e-4m  Cornelius value matching 10% flow 5m mesh
frac_aperature = 1.5e-4
frac_roughness = 10e-3 #was 12e-3
job_id = 0
# These should just be pass through, so high permeability, porosity ~1
inj_perm = 1.0e-9 #these are from the fracture volumetric fracture properties
inj_poro = .9
matrix_perm = 5.0e-17
matrix_poro = 2e-4 #2.0e-4 gives 90% recover and 2.5e-3 gives 50% mass recovery after 30 days

biot_coeff = 0.47

production_delay = 1 #time to start peaceman, should be 1e5s

endTime = 15768000 #half year
initial_dt = 100
dt_max = 50000

injection_temp = 323.15

mesh_size = 20

injection_point1 = '53.8865543998 225.4920635023 373.2999856190'
injection_point2 = '-13.3484490202,218.2456800420,404.5581304535'
injection_point3 = '-45.5934589398,214.7704112881,419.5491193579'

production_point1 = '-45.5934589398,214.7704112881,519.5491193579'
production_point2 = '-13.3484490202,218.2456800420,504.5581304535'
production_point3 = '53.8865543998,225.4920635023,473.2999856190'

# Tracer injection.
# These need to be defined even for nontracer runs because
# the mass injection times are added to injection function
# to make sure timesteps for injection are hit.
tracer_start_time = 864000
tracer_duration = 3600
tracer_end_time = '${fparse tracer_start_time+tracer_duration}'

# NOTE: water weight used in BCs and peacmeans
# because this is used in BCs, it should be reasonably physically correct,
# otherwise the BCs will be withdrawing or injecting water inappropriately.
# Note also that the 9300 should be the unit_weight in the PeacemanBoreholes
# 9300 = density(T=490K,P=23MPa) * gravity(9.8m/s2)
water_weight = 9300 #9300 = density(T=490K,P=23MPa) * gravity(9.8m/s2)

###########################################################
# Fracture materials
!include fracture_materials_nonlinear.i

# injection rates and postprocessors
!include injection_rates.i

# includding injection & production diracs
!include injection_pressure_diracs.i
!include injection_temperature_diracs.i

# includding injection & production pp
!include injection_pressure_pp.i
!include injection_temperature_pp.i
!include production_pressure_pp.i
!include production_temperature_pp.i
###########################################################

[PorousFlowFullySaturated]
  coupling_type = ThermoHydro
  porepressure = porepressure
  temperature = temperature
  fp = fp_water
  pressure_unit = Pa
  stabilization = full
[]
porepressure_outflow_component = 0

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = '3frac_Fractures_Local_${mesh_size}m_marked.e'
  []
  construct_node_list_from_side_list = false
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 -9.81'
[]

[Variables]
  [porepressure]
  []
  [temperature]
    scaling = 1e-6
  []
[]

[AuxVariables]
  [Pdiff]
    initial_condition = 0
  []
  [Tdiff]
    initial_condition = 0
  []
  [density]
    order = CONSTANT
    family = MONOMIAL
  []
  [viscosity]
    order = CONSTANT
    family = MONOMIAL
  []
  [insitu_pp]
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
  [Pdiff]
    type = ParsedAux
    use_xyzt = true
    variable = Pdiff
    coupled_variables = 'porepressure'
    expression = 'porepressure-(1.6025e7-${water_weight}*(z-1150))'
    execute_on = TIMESTEP_END
  []
  [Tdiff]
    type = ParsedAux
    use_xyzt = true
    variable = Tdiff
    coupled_variables = 'temperature'
    expression = 'temperature-(426.67-0.0733333*(z-1150))'
    execute_on = TIMESTEP_END
  []
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
  [insitu_T]
    type = ParsedFunction
    expression = '426.67-0.0733333*(z-1150)'
  []
  [insitu_pp]
    type = ParsedFunction
    expression = '1.6025e7-${water_weight}*(z-1150)'
  []
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
    function = insitu_pp
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
    mass_fraction_component = ${porepressure_outflow_component}
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
    function = insitu_pp
  []
  [temperature]
    type = FunctionIC
    variable = temperature
    function = insitu_T
  []
  [insitu_pp]
    type = FunctionIC
    variable = insitu_pp
    function = insitu_pp
  []
[]

[FluidProperties]
  # [the_simple_fluid]
  #   type = SimpleFluidProperties
  #   bulk_modulus = 2E9
  #   viscosity = 1.0E-3
  #   density0 = 1000.0
  # []
  # [true_water]
  #   type = Water97FluidProperties
  # []
  # [tabulated_water]
  #   type = TabulatedBicubicFluidProperties
  #   fluid_property_file = ext_fluid_properties2.csv
  #   # Bounds of interpolation
  #   # temperature_min = 280
  #   # temperature_max = 600
  # []
  [fp_water]
    type = IAPWS95LiquidFluidProperties
  []
[]

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
#April 2024 circulation test
# [Functions]
#   [mass_flux_src]
#     type = PiecewiseLinear
#     # in bpm
#     xy_data = "0	                  0
#                ${eqt} 	            0
#                ${fparse eqt+1} 	    2.5
#                ${fparse eqt+999} 	  2.5
#                ${fparse eqt+1000} 	6
#                ${fparse eqt+1680} 	6
#                ${fparse eqt+1681} 	11
#                ${fparse eqt+3000} 	11
#                ${fparse eqt+3001} 	15.5
#                ${fparse eqt+12420} 	15.5
#                ${fparse eqt+12421} 	13
#                ${fparse eqt+16560} 	13
#                ${fparse eqt+16561} 	0
#                ${fparse eqt+17700} 	0
#                ${fparse eqt+17701} 	13
#                ${fparse eqt+31621} 	13
#                ${fparse eqt+32200} 	10.5
#                ${fparse eqt+32201} 	10.5
#                ${fparse eqt+40000} 	0"

#     scale_factor = 2.65 #convert barrels/minute to kg/s
#   []
# []

#Simple 10bpm injection
[Functions]
  [mass_flux_src]
    type = PiecewiseLinear
    # in bpm
    xy_data = "0 0
               10000 10
               ${fparse tracer_start_time - 1} 10
               ${tracer_start_time} 10
               ${fparse tracer_end_time - 1} 10
               ${tracer_end_time} 10
               2320400 10"
    scale_factor = 2.65 #convert barrels/minute to kg/s
  []
[]

#April 2024 30 day circulation test from Pengju 2025/04/03
# extra lines added for tracer injection start/stop times
# [Functions]
#   [mass_flux_src]
#     type = PiecewiseLinear
#     # in bpm
#     xy_data = "0 0
#                1 2.5
#                85000 2.5
#                85001 0
#                114500 0
#                114501 2.5
#                143000 2.5
#                143001 5
#                186000 5
#                186001 7.5
#                247000 7.5
#                247001 10
#                ${fparse tracer_start_time - 1} 10
#                ${tracer_start_time} 10
#                ${fparse tracer_end_time - 1} 10
#                ${tracer_end_time} 10
#                435400 10
#                2320400 10
#                2320401 7.5
#                2321000 7.5
#                2321001 5
#                2321500 5
#                2321501 2.5
#                2322200 2.5
#                2322201 0
#                2325219 0
#                2325220 2.5
#                2325900 2.5
#                2325901 0
#                2332970 0
#                2332971 2.5
#                2334220 2.5
#                2334221 0
#                2345100 0
#                2345101 2.5
#                2348680 2.5
#                2348681 0"
#     scale_factor = 2.65 #convert barrels/minute to kg/s
#   []
# []
##########################################################
# PEACEMANS
[Functions]
  [insitu_pp_borehole]
    type = ParsedFunction
    symbol_names = 'back_pressure_Pa'
    symbol_values = '3.44738e6' #500psi back-pressure
    expression = '1.6025e7-${water_weight}*(z-1150)+back_pressure_Pa'
  []
  #delaying production for initial heaviside injection
  [character_function]
    type = PiecewiseLinear
    xy_data = "0 0
    ${fparse production_delay} 0
    ${fparse production_delay + 14500} 1"
  []
[]

[UserObjects]
  [borehole_fluid_outflow_mass]
    type = PorousFlowSumQuantity
  []
  [borehole_prod_temperature]
    type = PorousFlowSumQuantity
  []
[]

[DiracKernels]
  [withdraw_fluid]
    type = PorousFlowPeacemanBorehole
    variable = porepressure
    bottom_p_or_t = insitu_pp_borehole
    SumQuantityUO = borehole_fluid_outflow_mass
    point_file = peaceman_production_points.txt
    function_of = pressure
    fluid_phase = 0
    unit_weight = '0 0 -${water_weight}'
    use_mobility = true
    character = character_function
    point_not_found_behavior = WARNING
  []
  [bh_energy_flow]
    type = PorousFlowPeacemanBorehole
    variable = temperature
    bottom_p_or_t = insitu_pp_borehole
    SumQuantityUO = borehole_prod_temperature
    point_file = peaceman_production_points.txt
    function_of = pressure
    fluid_phase = 0
    unit_weight = '0 0 -${water_weight}'
    use_mobility = true
    use_enthalpy = true
    character = character_function
    point_not_found_behavior = WARNING
  []
[]

[Postprocessors]
  [fluid_report]
    type = PorousFlowPlotQuantity
    uo = borehole_fluid_outflow_mass
  []
  [energy_prod]
    type = PorousFlowPlotQuantity
    uo = borehole_prod_temperature
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
    function = mass_flux_src
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
  [p_well_58_bottom]
    type = PointValue
    variable = Pdiff
    point = '38.51767602 53.58355641 540.3684522'
  []
  [t_well_58_bottom]
    type = PointValue
    variable = Tdiff
    point = '38.51767602 53.58355641 540.3684522'
  []
[]


###########################################################
[Preconditioning]
  active = asm_ilu
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
  solve_type = NEWTON
  start_time = -1000
  end_time = ${endTime}
  dtmin = 0.5
  dtmax = ${dt_max}
  l_tol = 1e-4
  l_max_its = 200
  nl_max_its = 20
  nl_abs_tol = 1e-6
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
  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 20
    iteration_window = 5
    growth_factor = 1.2
    cutback_factor = 0.9
    cutback_factor_at_failure = 0.5
    linear_iteration_ratio = 1000
    dt = ${initial_dt}
    force_step_every_function_point = true
    post_function_sync_dt = 100
    timestep_limiting_function = mass_flux_src
  []
[]

##############################################################
[Outputs]
  file_base = 'outputs/results_nlmat_${mesh_size}m_${job_id}'
  csv = true
  print_linear_residuals = false
  [checkpoint]
    type = Checkpoint
    num_files = 2
    wall_time_interval = 72000 # seconds
  []
  [nem]
    file_base = 'outputs/result_${mesh_size}m_${job_id}'
    type = Nemesis
    sync_times = '0 86400 172800 259200 864000 1728000 2592000 8640000 15768000'
    sync_only = true
  []
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
