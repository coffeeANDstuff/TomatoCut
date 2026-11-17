"""Original fluted Santoku with octagonal walnut grip; Blender 4.3+."""
import json
import math
from pathlib import Path
import bpy
from mathutils import Matrix

ROOT = Path(__file__).resolve().parents[1]
data = next(d for d in json.loads((ROOT/'data/knives.json').read_text()) if d['id'] == 'santoku')
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


def mesh(name, vertices, faces, mat, bevel=.006):
    me = bpy.data.meshes.new(name)
    me.from_pydata(vertices, [], faces)
    me.update()
    ob = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(ob)
    ob.data.materials.append(mat)
    if bevel:
        mod = ob.modifiers.new('Hand-finished chamfers', 'BEVEL')
        mod.width = bevel
        mod.segments = 2
    return ob


def prism(name, outline, depth, z, mat):
    n = len(outline)
    return mesh(name, [(x, y, z+s*depth) for s in [-1, 1] for x, y in outline],
                [tuple(range(n-1, -1, -1)), tuple(range(n, 2*n))] +
                [(i, (i+1) % n, (i+1) % n+n, i+n) for i in range(n)], mat)


def octagon(name, rings, mat):
    vertices = [(x, .045+ry*math.cos(math.tau*(j+.5)/8), rz*math.sin(math.tau*(j+.5)/8))
                for x, ry, rz in rings for j in range(8)]
    faces = [tuple(range(7, -1, -1)), tuple(range((len(rings)-1)*8, len(rings)*8))]
    faces += [(r*8+j, r*8+(j+1) % 8, (r+1)*8+(j+1) % 8, (r+1)*8+j)
              for r in range(len(rings)-1) for j in range(8)]
    return mesh(name, vertices, faces, mat)


steel = material('Santoku soft brushed steel', (.40, .46, .49), .34, .82)
edge = material('Santoku fine honed silver', (.68, .72, .72), .25, .88)
walnut = material('Santoku oiled octagonal walnut', (.16, .083, .031), .57)
horn = material('Santoku charcoal ferrule', (.022, .033, .031), .40)
brass = material('Santoku narrow brass collar', (.40, .29, .11), .38, .72)
blade = prism('Tall sheepfoot Santoku blade', data['edge']+[[.91, .24], [.50, .34], [-.08, .34]], .028, 0, steel)
bpy.context.view_layer.objects.active = blade
for mod in list(blade.modifiers):
    bpy.ops.object.modifier_apply(modifier=mod.name)
# Real shallow elliptical hollows, baked offline; no runtime Boolean or decal.
for side in [-1, 1]:
    for x in [.05, .19, .33, .47, .61, .75]:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=12, location=(x, .13, side*.041))
        cutter = bpy.context.object
        cutter.scale = (.047, .075, .024)
        for face in cutter.data.polygons:
            face.use_smooth = True
        bpy.context.view_layer.objects.active = blade
        mod = blade.modifiers.new('Engraved elliptical granton hollow', 'BOOLEAN')
        mod.operation = 'DIFFERENCE'
        mod.solver = 'EXACT'
        mod.object = cutter
        bpy.ops.object.modifier_apply(modifier=mod.name)
        bpy.data.objects.remove(cutter, do_unlink=True)
blade.modifiers.new('Broad steel weighted normals', 'WEIGHTED_NORMAL')
prism('Santoku continuous lower honed facet', data['edge']+[[.89, -.013], [.65, -.073], [-.08, -.073]], .001, .029, edge)
octagon('Octagonal tapered walnut handle', [(-1.055, .10, .066), (-1.01, .119, .078), (-.70, .114, .075), (-.27, .106, .069)], walnut)
octagon('Charcoal octagonal ferrule', [(-.27, .108, .072), (-.10, .118, .075)], horn)
octagon('Narrow brass shoulder ring', [(-.105, .12, .077), (-.078, .12, .077)], brass)
octagon('Quiet steel heel cap', [(-1.06, .102, .068), (-1.04, .105, .070)], steel)

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
path = ROOT/'assets/models/knives/santoku.glb'
bpy.ops.export_scene.gltf(filepath=str(path), export_format='GLB', use_selection=True, export_apply=True)
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(path))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/santoku.blend'))
