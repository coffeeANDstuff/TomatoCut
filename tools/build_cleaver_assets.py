"""Original short heavy Cleaver, real hanging eye and riveted umber grip."""
from pathlib import Path
import json
import sys
import bpy
sys.path.insert(0, str(Path(__file__).resolve().parent))
from blender_meshes import ROOT, clear, material, prism, export

DATA = next(d for d in json.loads((ROOT/'data/knives.json').read_text()) if d['id'] == 'cleaver')
clear()
steel = material('Cleaver broad satin steel', (.40, .47, .49), .51, .55)
edge = material('Cleaver broad honed bevel', (.70, .75, .74), .44, .43)
tang = material('Cleaver dark forged tang', (.12, .145, .14), .48, .67)
wood = material('Cleaver burnt-umber handle scales', (.20, .065, .025), .58)
grain = material('Cleaver modeled umber growth lines', (.09, .032, .014), .64)
brass = material('Cleaver flush warm brass pins', (.44, .29, .10), .44, .70)

blade = prism('Heavy rectangular Cleaver blade', DATA['edge']+[[1.10, .50], [.94, .62], [-.08, .62]], .044, 0, steel, .014)
bpy.context.view_layer.objects.active = blade
for mod in list(blade.modifiers):
    bpy.ops.object.modifier_apply(modifier=mod.name)
# A real through-hole, not a black painted circle.
bpy.ops.mesh.primitive_cylinder_add(vertices=48, radius=.082, depth=.30, location=(.83, .44, 0))
cutter = bpy.context.object
bpy.context.view_layer.objects.active = blade
mod = blade.modifiers.new('Real Cleaver hanging eye', 'BOOLEAN')
mod.operation = 'DIFFERENCE'
mod.solver = 'EXACT'
mod.object = cutter
bpy.ops.object.modifier_apply(modifier=mod.name)
bpy.data.objects.remove(cutter, do_unlink=True)
mod = blade.modifiers.new('Rounded hanging-eye lip', 'BEVEL')
mod.width = .003
mod.segments = 2
blade.modifiers.new('Broad forged weighted normals', 'WEIGHTED_NORMAL')
facet = DATA['edge']+[[1.075, -.095], [.83, -.125], [-.08, -.125]]
for side in [-1, 1]:
    prism('Heavy double-sided Cleaver bevel', facet, .001, side*.045, edge, .001)
handle = [(-1.06, -.085), (-.92, -.15), (-.66, -.15), (-.38, -.10), (-.18, -.13),
          (-.12, -.04), (-.15, .16), (-.38, .18), (-.69, .14), (-.96, .19), (-1.08, .10)]
prism('Full heavy dark Cleaver tang', handle, .062, 0, tang, .025)
for side in [-1, 1]:
    prism('Sculpted burnt-umber Cleaver scale', [(x, y*.92) for x, y in handle], .028, side*.067, wood, .027)
    for j in range(3):
        y = -.035+j*.047
        prism('Quiet modeled Cleaver wood grain', [(-.95, y), (-.72, y-.011), (-.46, y+.012), (-.27, y+.004), (-.46, y+.018), (-.72, y-.005)], .0007, side*.096, grain, .0003)
prism('Dark squared Cleaver ferrule', [(-.22, -.16), (-.08, -.19), (-.08, .27), (-.22, .20)], .082, 0, tang, .014)
for x, y in [(-.88, .014), (-.43, .020)]:
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=.032, depth=.199, location=(x, y, 0))
    ob = bpy.context.object
    ob.name = 'Two flush Cleaver brass rivets'
    ob.data.materials.append(brass)
    mod = ob.modifiers.new('Soft rivet lips', 'BEVEL')
    mod.width = .004
    mod.segments = 2
    ob.modifiers.new('Rivet weighted normals', 'WEIGHTED_NORMAL')
export('assets/models/knives/cleaver.glb')
bpy.ops.import_scene.gltf(filepath=str(ROOT/'assets/models/knives/cleaver.glb'))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/cleaver.blend'))
