"""Original balanced Utility Knife; Blender 4.3+, geometry follows knives.json."""
from pathlib import Path
import json
import math
import bpy
from mathutils import Matrix

ROOT = Path(__file__).resolve().parents[1]
data = next(d for d in json.loads((ROOT/'data/knives.json').read_text()) if d['id'] == 'utility')
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)


def material(name, color, roughness, metal=0):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    p = m.node_tree.nodes['Principled BSDF']
    p.inputs['Base Color'].default_value = m.diffuse_color
    p.inputs['Roughness'].default_value = roughness
    p.inputs['Metallic'].default_value = metal
    return m


def prism(name, outline, depth, z, mat, bevel):
    n = len(outline)
    vertices = [(x, y, z+side*depth) for side in [-1, 1] for x, y in outline]
    faces = [tuple(range(n-1, -1, -1)), tuple(range(n, 2*n))]
    faces += [(i, (i+1) % n, (i+1) % n+n, i+n) for i in range(n)]
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    ob = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(ob)
    ob.data.materials.append(mat)
    mod = ob.modifiers.new('Soft hand-finished edges', 'BEVEL')
    mod.width = bevel
    mod.segments = 3
    ob.modifiers.new('Weighted steel and wood normals', 'WEIGHTED_NORMAL')
    return ob


steel = material('Utility brushed nickel steel', (.43, .49, .51), .34, .82)
edge = material('Utility pale honed bevel', (.70, .73, .70), .25, .88)
wood = material('Oiled winewood scales', (.19, .043, .035), .52)
grain = material('Fine winewood growth lines', (.085, .021, .018), .58)
ivory = material('Ivory heel inlay', (.66, .57, .38), .48)
outline = data['edge'] + [[.88, .205], [.38, .24], [-.08, .205]]
prism('Balanced rising utility blade', outline, .025, 0, steel, .006)
prism('Continuous honed lower facet', data['edge'] + [[.95, -.012], [.67, -.048], [-.08, -.048]], .001, .026, edge, .001)
handle = [(-1.02, -.05), (-.92, -.11), (-.67, -.12), (-.40, -.09), (-.18, -.105), (-.13, -.045), (-.13, .14), (-.40, .155), (-.70, .115), (-.96, .15), (-1.035, .10)]
prism('Full utility steel tang', handle, .047, 0, steel, .02)
for z in [-.051, .051]:
    prism('Sculpted winewood handle scale', [(x, y*.93) for x, y in handle], .024, z, wood, .025)
    for j in range(3):
        y = -.035+j*.045
        prism('Fine curved wood grain', [(-.91, y), (-.69, y-.009), (-.43, y+.012), (-.29, y+.005), (-.44, y+.017), (-.69, y-.004)], .001, z+(.025 if z > 0 else -.025), grain, .0005)
prism('Stepped nickel bolster', [(-.19, -.12), (-.075, -.10), (-.075, .22), (-.19, .17)], .063, 0, steel, .012)
prism('Angled ivory heel', [(-1.02, -.047), (-.945, -.08), (-.92, .127), (-1.02, .10)], .079, 0, ivory, .01)
for x, y in [(-.82, .008), (-.52, .019), (-.27, .018)]:
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=.024, depth=.159, location=(x, y, 0))
    ob = bpy.context.object
    ob.name = 'Flush nickel utility pin'
    ob.data.materials.append(steel)

bpy.context.view_layer.update()
for ob in list(bpy.context.scene.objects):
    bpy.context.view_layer.objects.active = ob
    for mod in list(ob.modifiers):
        bpy.ops.object.modifier_apply(modifier=mod.name)
    ob.matrix_world = Matrix.Rotation(math.pi/2, 4, 'X') @ ob.matrix_world
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
assert len(bpy.context.scene.objects) <= 8
bpy.ops.object.select_all(action='SELECT')
path = ROOT/'assets/models/knives/utility.glb'
bpy.ops.export_scene.gltf(filepath=str(path), export_format='GLB', use_selection=True, export_apply=True)
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(path))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/utility_knife.blend'))
