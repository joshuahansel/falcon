x_inj = 0
x_ext = 30
x_middle = ${fparse 0.5 * (x_inj + x_ext)}

z_frac1 = -20
z_frac2 = -30

point_frac1_inj = '${x_inj} 0 ${z_frac1}'
point_frac1_ext = '${x_ext} 0 ${z_frac1}'

point_frac2_inj = '${x_inj} 0 ${z_frac2}'
point_frac2_ext = '${x_ext} 0 ${z_frac2}'

T_inlet = 300
p_outlet = 1e5

p_reference_point = '0 0 0'
