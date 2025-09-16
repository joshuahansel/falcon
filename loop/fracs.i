!include params_base.i
!include params_fracs.i

!include part_base.i

[Components]
  [frac1_wall1]
    type = SolidWall1Phase
    input = 'frac1:in'
  []
  [frac1]
    type = FlowChannel1Phase
    position = '${x_frac_left} 0 ${z_frac1}'
    orientation = '1 0 0'
    length = ${L_frac}
    n_elems = ${n_elems_frac}
    A = ${A_frac}
  []
  [outlet]
    type = Outlet1Phase
    input = 'frac1:out'
    p = ${p_outlet}
  []

  [junction_inj_frac1]
    type = DiracSource1Phase
    flow_channel = frac1
    point = ${point_frac1_inj}
    mass_source_rate = mdot_frac1_inj_main
    energy_source_rate = Edot_frac1_inj_main
  []
[]

[Postprocessors]
  [p_frac1_inj]
    type = PointValue
    point = ${point_frac1_inj}
    variable = p
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [T_frac1_inj]
    type = PointValue
    point = ${point_frac1_inj}
    variable = T
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [mdot_frac1_inj_main]
    type = Receiver
  []
  [Edot_frac1_inj_main]
    type = Receiver
  []
[]
