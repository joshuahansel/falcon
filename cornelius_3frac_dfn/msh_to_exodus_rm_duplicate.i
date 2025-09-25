# created by write_txt_for_3D_fracture_mesher.py
# This is a MOOSE input file to remove duplicate elements from sidesets created by Andy's script
# Run it using:  falcon-opt -i msh_to_exodus_rm_duplicate.i mesh_size=20 --mesh-only 3frac_Fractures_Local_20m.e
mesh_size='20'
[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 3frac_Fractures_Local_${mesh_size}m.msh
  []
  [rename]
    type = RenameBlockGenerator
    input = fmg
    old_block = '4'
    new_block = '1000'
  []
  [rmDuplicateSS]
    type = RemoveDuplicateFacesFromSidesets
    input = rename
  []
  [fracture1]
    type = LowerDBlockFromSidesetGenerator
    input = rmDuplicateSS
    new_block_id = 1
    new_block_name = 'fracture1'
    sidesets = 'disk1'
  []
  [fracture2]
    type = LowerDBlockFromSidesetGenerator
    input = fracture1
    new_block_id = 2
    new_block_name = 'fracture2'
    sidesets = 'disk2'
  []
  [fracture3]
    type = LowerDBlockFromSidesetGenerator
    input = fracture2
    new_block_id = 3
    new_block_name = 'fracture3'
    sidesets = 'disk3'
  []
[]