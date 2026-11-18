"""Original forged Chef's Knife; actual cutting belly follows knives.json."""
from pathlib import Path
import json
import math
import bpy
from mathutils import Matrix

ROOT = Path(__file__).resolve().parents[1]
DATA = next(d for d in json.loads((ROOT/'data/knives.json').read_text()) if d['id'] == 'chef')
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)


def material(name, color, roughness, metal=0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    shader = mat.node_tree.nodes['Principled BSDF']
    shader.inputs['Base Color'].default_value = mat.diffuse_color
    shader.inputs['Roughness'].default_value = roughness
    shader.inputs['Metallic'].default_value = metal
    return mat


def prism(name, outline, depth, z, mat, bevel=.007):
    n = len(outline)
    data = bpy.data.meshes.new(name)
    data.from_pydata([(x, y, z+side*depth) for side in [-1, 1] for x, y in outline], [],
                     [tuple(range(n-1, -1, -1)), tuple(range(n, 2*n))]+
                     [(i, (i+1) % n, (i+1) % n+n, i+n) for i in range(n)])
    data.update()
    ob = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(ob)
    ob.data.materials.append(mat)
    if bevel:
        mod = ob.modifiers.new('Forged shoulder and scale chamfers', 'BEVEL')
        mod.width = bevel
        mod.segments = 3
    ob.modifiers.new('Broad polished weighted normals', 'WEIGHTED_NORMAL')
    return ob


steel = material('Chef satin forged carbon steel', (.52, .58, .61), .34, .60)
edge = material('Chef continuous polished cutting bevel', (.78, .81, .79), .28, .45)
ebony = material('Chef sculpted charcoal ebony scales', (.027, .033, .030), .48)
grain = material('Chef quiet ebony growth lines', (.065, .068, .048), .55)
brass = material('Chef warm flush brass pins', (.44, .31, .12), .38, .73)
ivory = material('Chef small ivory maker diamond', (.73, .66, .47), .43)

outline = DATA['edge']+[[1.035, .33], [.55, .44], [-.08, .40]]
prism('Long curved forged Chef blade', outline, .030, 0, steel, .006)
facet = DATA['edge']+[[1.22, .093], [.94, -.026], [.55, -.083], [-.08, -.083]]
for side in [-1, 1]:
    prism('Continuous double-sided Chef honed facet', facet, .001, side*.031, edge, .001)
handle = [(-1.16, -.09), (-1.01, -.14), (-.77, -.12), (-.51, -.075), (-.32, -.11),
          (-.18, -.11), (-.15, -.025), (-.18, .15), (-.40, .17), (-.72, .14), (-1.09, .17), (-1.18, .10)]
prism('Full forged Chef tang', handle, .052, 0, steel, .018)
for side in [-1, 1]:
    z = side*.058
    prism('Sculpted ebony Chef scale', [(x, y*.92) for x, y in handle], .025, z, ebony, .023)
    for j in range(3):
        y = -.030+j*.040
        prism('Restrained modeled ebony grain', [(-1.04, y), (-.80, y-.010), (-.57, y+.015),
              (-.37, y+.009), (-.57, y+.019), (-.80, y-.006)], .0006, side*.084, grain, .0003)
    # A small original maker's lozenge; no external font or logo.
    prism('Small ivory maker lozenge', [(-.78, .018), (-.735, -.015), (-.69, .018), (-.735, .050)], .0008, side*.085, ivory, .001)
prism('Full polished finger bolster', [(-.22, -.16), (-.075, -.155), (-.075, .405), (-.20, .28)], .077, 0, steel, .018)
for x, y in [(-1.04, .020), (-.88, .013), (-.40, .021)]:
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=.023, depth=.171, location=(x, y, 0))
    ob = bpy.context.object
    ob.name = 'Three flush Chef brass rivets'
    ob.data.materials.append(brass)
    mod = ob.modifiers.new('Rivet lip chamfer', 'BEVEL')
    mod.width = .003
    mod.segments = 2
    ob.modifiers.new('Rivet weighted normals', 'WEIGHTED_NORMAL')

bpy.context.view_layer.update()
for ob in list(bpy.context.scene.objects):
    bpy.context.view_layer.objects.active = ob
    for mod in list(ob.modifiers):
        bpy.ops.object.modifier_apply(modifier=mod.name)
    ob.matrix_world = Matrix.Rotation(math.pi/2, 4, 'X') @ ob.matrix_world
count = sum(len(ob.data.vertices) for ob in bpy.context.scene.objects)
groups = {}
for ob in list(bpy.context.scene.objects):
    groups.setdefault(tuple(m.name for m in ob.data.materials), []).append(ob)
for objects in groups.values():
    bpy.ops.object.select_all(action='DESELECT')
    for ob in objects:
        ob.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    if len(objects) > 1:
        bpy.ops.object.join()
assert sum(len(ob.data.vertices) for ob in bpy.context.scene.objects) == count
assert len(bpy.context.scene.objects) <= 8
bpy.ops.object.select_all(action='SELECT')
path = ROOT/'assets/models/knives/chef.glb'
bpy.ops.export_scene.gltf(filepath=str(path), export_format='GLB', use_selection=True, export_apply=True)
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(path))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/chef_knife.blend'))
