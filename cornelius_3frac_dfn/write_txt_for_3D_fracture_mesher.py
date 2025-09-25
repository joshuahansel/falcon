import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


# function for plotting circles.
def plot_circle(df):
    # Create a 3D plot
    fig = plt.figure()
    ax = fig.add_subplot(111, projection="3d")
    # Plot each fracture as a circle
    for index, row in df.iterrows():
        center = [row["FractureX[m]"], row["FractureY[m]"], row["FractureZ[m]"]]
        radius = row["FractureRadius[m]"]
        trend_deg = row["Trend[deg]"]
        plunge_deg = row["Plunge[deg]"]
        strike_deg = row["Strike[deg]"]

        center = np.array(center)
        strike_radians = np.radians(strike_deg)
        dip_trend_radians = np.radians(trend_deg)
        dip_plunge_radians = np.radians(plunge_deg)
        strike = (np.sin(strike_radians), np.cos(strike_radians), 0)
        dip = (
            np.sin(dip_trend_radians) * np.cos(dip_plunge_radians),
            np.cos(dip_trend_radians) * np.cos(dip_plunge_radians),
            -np.sin(dip_plunge_radians),
        )
        if strike[0] * dip[0] + strike[1] * dip[1] > 1e-6:
            v1 = strike / np.linalg.norm(strike)
            v2 = dip / np.linalg.norm(dip)
            angle_radian = np.arccos(np.clip(np.dot(v1, v2), -1.0, 1.0))
            print(
                f"This strike and dip are not exactly perpendicular: strike-dip=[{np.rad2deg(angle_radian)}]  \n trend[{trend_deg}]; plunge[{plunge_deg}]; strike[{strike_deg}]"
            )

        unit_normal = (
            strike[1] * dip[2] - strike[2] * dip[1],
            strike[2] * dip[0] - strike[0] * dip[2],
            strike[0] * dip[1] - strike[1] * dip[0],
        )
        normal = unit_normal / np.linalg.norm(unit_normal)
        # Create two orthogonal vectors in the plane of the circle
        if normal[0] == 0 and normal[1] == 0:
            orthogonal1 = np.array([1, 0, 0])
        else:
            orthogonal1 = np.array([-normal[1], normal[0], 0])
        orthogonal1 = orthogonal1 / np.linalg.norm(orthogonal1)
        orthogonal2 = np.cross(normal, orthogonal1)
        # Create the circle points
        theta = np.linspace(0, 2 * np.pi, 20)
        circle_points = (
            center[:, np.newaxis]
            + radius * np.cos(theta) * orthogonal1[:, np.newaxis]
            + radius * np.sin(theta) * orthogonal2[:, np.newaxis]
        )
        ax.plot(circle_points[0], circle_points[1], circle_points[2])

    # Set labels
    ax.set_xlabel("X [m]")
    ax.set_ylabel("Y [m]")
    ax.set_zlabel("Z [m]")

    # Add an arrow to indicate the north direction
    arrow_start = [0, 0, 0]
    arrow_end = [100, 0, 0]  # Adjust length as needed
    ax.quiver(
        arrow_start[0],
        arrow_start[1],
        arrow_start[2],
        arrow_end[0],
        arrow_end[1],
        arrow_end[2],
        color="k",
        arrow_length_ratio=0.1,
    )
    ax.text(arrow_end[0], arrow_end[1], arrow_end[2], "North", color="k")

    # Show plot
    plt.show()


#
#
#
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
# Read the CSV file
frac_name_prefix = "3frac"
mesh_output_dir = "."
fname = "3fracs.csv"
df = pd.read_csv(fname)

# correct Aleta's plunge direction for Andys gmsh script
df["Plunge[deg]"] = df["Plunge[deg]"] + 90  # FIXME  DON"T FORGET THIS!!!
df["Tag"] = range(1, len(df) + 1)
df["MeshSize"] = 10

# write output in format for Andys gmsh script.
# Write the string and DataFrame to a file
# Define the string to be written as the first line
xmin = -2100
xmax = 2100
ymin = -2000
ymax = 2400
zmin = -1500
zmax = 2400
matrix_mesh_size = 300
bounding_box_output = (
    f"bounding_box {xmin} {xmax} {ymin} {ymax} {zmin} {zmax} {matrix_mesh_size}"
)
#
# Select specific columns to be written to the file
selected_columns = [
    "FractureX[m]",
    "FractureY[m]",
    "FractureZ[m]",
    "FractureRadius[m]",
    "Trend[deg]",
    "Plunge[deg]",
    "Strike[deg]",
    "Aperture[m]",
    "Tag",
    "MeshSize",
]
#
fracture_mesh_size = 20
with open(
    f"{mesh_output_dir}/{frac_name_prefix}_Fractures_Local_{fracture_mesh_size}m.txt",
    "w",
) as f:
    f.write(bounding_box_output + "\n")
    df["MeshSize"] = fracture_mesh_size
    df_selected = df[selected_columns]
    df_selected.to_csv(f, sep="\t", index=False)
#
fracture_mesh_size = 10
with open(
    f"{mesh_output_dir}/{frac_name_prefix}_Fractures_Local_{fracture_mesh_size}m.txt",
    "w",
) as f:
    f.write(bounding_box_output + "\n")
    df["MeshSize"] = fracture_mesh_size
    df_selected = df[selected_columns]
    df_selected.to_csv(f, sep="\t", index=False)
#
fracture_mesh_size = 5
with open(
    f"{mesh_output_dir}/{frac_name_prefix}_Fractures_Local_{fracture_mesh_size}m.txt",
    "w",
) as f:
    f.write(bounding_box_output + "\n")
    df["MeshSize"] = fracture_mesh_size
    df_selected = df[selected_columns]
    df_selected.to_csv(f, sep="\t", index=False)
#
fracture_mesh_size = 2
with open(
    f"{mesh_output_dir}/{frac_name_prefix}_Fractures_Local_{fracture_mesh_size}m.txt",
    "w",
) as f:
    f.write(bounding_box_output + "\n")
    df["MeshSize"] = fracture_mesh_size
    df_selected = df[selected_columns]
    df_selected.to_csv(f, sep="\t", index=False)
#
#
# **************************************************************************************
#
# create moose gmsh conversion file that will place every fracture into its own block
#
# *************************************************************************************
with open(f"{mesh_output_dir}/msh_to_exodus_rm_duplicate.i", "w") as file:
    file.write("# created by write_txt_for_3D_fracture_mesher.py\n")
    file.write(
        "# This is a MOOSE input file to remove duplicate elements from sidesets created by Andy's script\n"
    )
    file.write(
        f"# Run it using:  falcon-opt -i msh_to_exodus_rm_duplicate.i mesh_size=20 --mesh-only {frac_name_prefix}_Fractures_Local_20m.e\n"
    )

    file.write("mesh_size='20'\n")
    file.write("[Mesh]\n")
    file.write("  [fmg]\n")
    file.write("    type = FileMeshGenerator\n")
    file.write(f"    file = {frac_name_prefix}_Fractures_Local_${{mesh_size}}m.msh\n")
    file.write("  []\n")
    file.write("  [rename]\n")
    file.write("    type = RenameBlockGenerator\n")
    file.write("    input = fmg\n")
    file.write(f"    old_block = '{len(df)+1}'\n")
    file.write("    new_block = '1000'\n")
    file.write("  []\n")
    file.write("  [rmDuplicateSS]\n")
    file.write("    type = RemoveDuplicateFacesFromSidesets\n")
    file.write("    input = rename\n")
    file.write("  []\n")
    for index in range(len(df)):
        file.write(f"  [fracture{index+1}]\n")
        file.write("    type = LowerDBlockFromSidesetGenerator\n")
        if index == 0:
            file.write("    input = rmDuplicateSS\n")
        else:
            file.write(f"    input = fracture{index}\n")
        file.write(f"    new_block_id = {index+1}\n")
        file.write(f"    new_block_name = 'fracture{index+1}'\n")
        file.write(f"    sidesets = 'disk{index+1}'\n")
        file.write("  []\n")

    file.write("[]")
# *************************************************************************************

# PLOT IF YOU WANT!
plot_circle(df)
