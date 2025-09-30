

def compute_T(z):
  return 426.67-0.0733333*(z-1150)

# def compute_p(z):
#   return 1.6025e7-9300*(z-1150)

z_surf = 2800
# z_surf = 1550

print(compute_T(z_surf))
# print(compute_p(z_surf))

# rhog = 9300
# z_ref = 1150
# p_s = 101.325e3
# p_ref = 1.6025e7

# z_s = z_ref + (p_ref - p_s) / rhog
# print(z_s)

