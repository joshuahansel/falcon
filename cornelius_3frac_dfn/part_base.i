
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
