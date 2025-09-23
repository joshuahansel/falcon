[Functions]
  [inlet_mdot_fn]
    type = TimeRampFunction
    initial_value = 0
    final_value = ${mdot_inlet_final}
    ramp_duration = ${mdot_ramp_time}
  []
[]

# [ChainControls]
#   [get_inlet_mdot_ctrl]
#     type = GetPostprocessorChainControl
#     postprocessor = inlet_mdot
#   []
#   [inlet_mdot_setpoint]
#     type = GetFunctionValueChainControl
#     # function = 1.0
#     function = 10.0
#   []
#   [inlet_p0_ctrl]
#     type = PIDChainControl
#     input = get_inlet_mdot_ctrl:value
#     set_point = inlet_mdot_setpoint:value
#     K_p = 1.0
#     K_i = 0
#     K_d = 0
#   []
#   [set_inlet_p0_ctrl]
#     type = SetRealValueChainControl
#     parameter = Components/inlet/p0
#     # value = inlet_p0_ctrl:value
#     value = inlet_mdot_setpoint:value
#   []
# []

[ControlLogic]
  [inlet_mdot_setpoint]
    type = GetFunctionValueControl
    function = inlet_mdot_fn
  []
  # [inlet_p0_ctrl]
  #   type = PIDControl
  #   input = inlet_mdot
  #   set_point = inlet_mdot_setpoint:value
  #   K_p = 1.0
  #   K_i = 0
  #   K_d = 0
  #   initial_value = 0
  # []
  # [set_inlet_p0_ctrl]
  #   type = SetRealValueControl
  #   # parameter = Components/inlet/p0
  #   parameter = Components/inlet/m_dot
  #   # value = inlet_p0_ctrl:value
  #   value = inlet_mdot_setpoint:value
  # []
  # [set_inlet_p0_ctrl]
  #   type = SetComponentRealValueControl
  #   component = inlet
  #   parameter = p0
  #   value = inlet_p0_ctrl:output
  # []
  [set_inlet_mdot_ctrl]
    type = SetComponentRealValueControl
    component = inlet
    parameter = m_dot
    value = inlet_mdot_setpoint:value
  []
[]

[Postprocessors]
  [inlet_mdot]
    type = ADFlowBoundaryFlux1Phase
    boundary = inlet
    equation = mass
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
