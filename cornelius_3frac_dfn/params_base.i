initial_time = -1000
final_time = 15768000 #half year

gravity_vector = '0 0 -9.80665'

# z_surface = 1550 # value provided by Lynn
z_surface = 2800 # value in FORGE input file

x1 = -45.5934589398
y1 = 214.7704112881

inj_point1 = '${x1} ${y1} 419.5491193579'
inj_point2 = '-13.3484490202 218.2456800420 404.5581304535'
inj_point3 = '53.8865543998 225.4920635023 373.2999856190'

pro_point1 = '${x1} ${y1} 519.5491193579'
pro_point2 = '-13.3484490202 218.2456800420 504.5581304535'
pro_point3 = '53.8865543998 225.4920635023 473.2999856190'

# NOTE: water weight used in BCs and peacmeans
# because this is used in BCs, it should be reasonably physically correct,
# otherwise the BCs will be withdrawing or injecting water inappropriately.
# Note also that the 9300 should be the unit_weight in the PeacemanBoreholes
# 9300 = density(T=490K,P=23MPa) * gravity(9.8m/s2)
# water_weight = 9300 #9300 = density(T=490K,P=23MPa) * gravity(9.8m/s2)
