import pandas as pd
import numpy as np
import csv

# Create a material property file for each individual fracture.

print(
    "\n********************************************\n"
    "Step 1: write_txt_for_3D_fracture_mesher.py\n"
    "Step 2: Choose method to find pipe dfn intersections: \n"
    "    dfn_well_intersections.py  - finding where line intersects fractures \n"
    "    dfn_well_intersectionsFromAleta.py  - using intersections provided by Aleta \n"
    "Step 3: write_diracs_input.py \n"
    "Step 4: write_nl_frac_materials_input.py or write_constant_frac_materials_input.py \n"
    "********************************************\n"
)

# Define the precision you want
precision = 10

# Read the CSV file
output_dir = "."
df = pd.read_csv("3fracs.csv")

# correct Aleta's plunge direction for Andys gmsh script
df["Plunge[deg]"] = df["Plunge[deg]"] + 90  # FIXME  DON"T FORGET THIS!!!


############ WRITE DIRAC KERNELS
with open(f"{output_dir}/fracture_materials_nonlinear.i", "w") as file:
    file.write("# created by write_frac_materials_input.py\n")
    file.write("# see Materials Property section in porous flow notes: \n")
    file.write(
        "# https://mooseframework.inl.gov/modules/porous_flow/multiapp_fracture_flow_PorousFlow_3D.html \n"
    )
    file.write("# DFN from fname \n")
    all_frac_block_id_string = '"'
    # creating string with all fracture block names in it.  Naming is from write_txt_for_3D_fracture_mesher.py
    for index in range(len(df)):
        all_frac_block_id_string += f"fracture{index+1} "
    all_frac_block_id_string += '"'
    file.write(f"all_frac_ids = {all_frac_block_id_string}\n\n")

    for index in range(len(df)):
        file.write(f"frac_aperture_{index + 1} = ${{frac_aperature}}\n")
    file.write("\n")
    for index in range(len(df)):
        file.write(f"frac_roughness_{index + 1} = ${{frac_roughness}}\n")
    file.write("\none_over_bulk = 1.4e-11 #bulk modulus = 70GPa\n")

    file.write("\n[Materials]\n")
    # porosity properties
    for index, row in df.iterrows():
        x = row["FractureX[m]"]
        y = row["FractureY[m]"]
        z = row["FractureZ[m]"]
        poro_frac_name = "frac_aperture_" + str(index + 1)
        l1 = f"  [porosity_fracture{int(index+1)}]"
        l2 = f"    type = PorousFlowPorosityLinear"
        l3 = f"    porosity_ref = ${{{poro_frac_name}}}"
        l4 = f"    P_ref = insitu_pp"
        l5 = f"    P_coeff = ${{one_over_bulk}}"
        l6 = f"    porosity_min = ${{fparse {poro_frac_name}/10}}"
        l7 = f"    block = fracture{index+1}"
        l8 = f"  []"
        file.write(
            l1
            + "\n"
            + l2
            + "\n"
            + l3
            + "\n"
            + l4
            + "\n"
            + l5
            + "\n"
            + l6
            + "\n"
            + l7
            + "\n"
            + l8
            + "\n"
        )
    # permeability properties
    for index, row in df.iterrows():
        roughness_name = "frac_roughness_" + str(index + 1)
        aperture_name = "frac_aperture_" + str(index + 1)
        l1 = f"  [permeability_fracture{int(index+1)}]"
        l2 = f"    type = PorousFlowPermeabilityKozenyCarman"
        l3 = f"    k0 = ${{fparse {roughness_name}/12*{aperture_name}^3}}"
        l4 = f"    poroperm_function = kozeny_carman_phi0"
        l5 = f"    m = 0"
        l6 = f"    n = 3"
        l7 = f"    phi0 = ${{{aperture_name}}}"
        l8 = f"    block = fracture{index+1}"
        l9 = f"  []"
        file.write(
            l1
            + "\n"
            + l2
            + "\n"
            + l3
            + "\n"
            + l4
            + "\n"
            + l5
            + "\n"
            + l6
            + "\n"
            + l7
            + "\n"
            + l8
            + "\n"
            + l9
            + "\n"
        )

    file.write("\n")
    # rock_internal_energy_fracture properties
    l1 = f"  [rock_internal_energy_fracture]"
    l2 = f"    type = PorousFlowMatrixInternalEnergy"
    l3 = f"    density = 2500"
    l4 = f"    specific_heat_capacity = 100.0"
    l5 = f"    block = ${{all_frac_ids}}"
    l6 = f"  []"
    file.write(l1 + "\n" + l2 + "\n" + l3 + "\n" + l4 + "\n" + l5 + "\n" + l6 + "\n")
    file.write("\n")
    # thermal_conductivity_fracture properties
    l1 = f"  [thermal_conductivity_fracture]"
    l2 = f"    type = PorousFlowThermalConductivityIdeal"
    l3 = f"    dry_thermal_conductivity = '3 0 0 0 3 0 0 0 3'"
    l4 = f"    block = ${{all_frac_ids}}"
    l5 = f"  []"
    file.write(l1 + "\n" + l2 + "\n" + l3 + "\n" + l4 + "\n" + l5 + "\n")

    file.write("[]\n")
