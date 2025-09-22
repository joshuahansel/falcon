
L_injext = 50
n_elems_injext = 50

z_wells_bottom = ${fparse -L_injext}

A_injext = 0.1
# A_inj_frac1 = 0.1
A_inj_frac1 = 1e-2
A_ext_frac1 = 1e-2

mdot_inlet_final = 1.0
mdot_ramp_time = 100.0

wells_blocks = 'inj_pipe'

max_p_change_tol = 1.0
