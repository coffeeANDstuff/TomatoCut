"""Original forged Steak Knife; Blender 4.3.2. Earlier models stay intact."""
from pathlib import Path
import math
import bpy
from mathutils import Matrix

ROOT = Path(__file__).resolve().parents[1]
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)


def material(name, color, roughness, metal=0):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    shader = m.node_tree.nodes['Principled BSDF']
    shader.inputs['Base Color'].default_value = m.diffuse_color
    shader.inputs['Roughness'].default_value = roughness
    shader.inputs['Metallic'].default_value = metal
    return m


steel = material('Polished forged steel', (.43, .48, .47), .27, .78)
olive = material('Oiled olivewood grip', (.28, .15, .055), .59)
brass = material('Brass grip rivets', (.40, .29, .11), .36, .72)


def prism(name, outline, depth, z, mat, bevel_width):
    n = len(outline)
    verts = [(x, y, z+d) for d in [-depth, depth] for x, y in outline]
    faces = [tuple(range(n-1, -1, -1)), tuple(range(n, 2*n))]
    faces += [(i, (i+1) % n, (i+1) % n+n, i+n) for i in range(n)]
    mesh = bpy.data.meshes.new(name+' mesh')
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    ob = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(ob)
    ob.data.materials.append(mat)
    bevel = ob.modifiers.new('Forged rounded edges', 'BEVEL')
    bevel.width = bevel_width
    bevel.segments = 3
    ob.modifiers.new('Weighted surface normals', 'WEIGHTED_NORMAL')
    return ob


# Lower three points are the exact cutting polyline in knives.json.
prism('Tapered forged steak blade', [(-.08, -.09), (.64, -.09), (.88, .035), (.65, .16), (-.08, .18)], .019, 0, steel, .006)
grip = [(-.92, -.05), (-.84, -.11), (-.65, -.125), (-.43, -.095), (-.22, -.13), (-.15, -.08), (-.15, .115), (-.40, .15), (-.75, .14), (-.91, .095)]
prism('Visible full steel tang', grip, .039, 0, steel, .026)
for z in [-.044, .044]:
    prism('Curved olivewood handle scale', [(x, y*.94) for x, y in grip], .025, z, olive, .031)
prism('Steel bolster', [(-.18, -.14), (-.08, -.12), (-.08, .19), (-.18, .17)], .045, 0, steel, .015)
for x, y in [(-.77, .015), (-.51, .025), (-.27, .015)]:
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=.027, depth=.145, location=(x, y, 0))
    ob = bpy.context.object
    ob.name = 'Brass through rivet'
    ob.data.materials.append(brass)
    bevel = ob.modifiers.new('Rivet rim', 'BEVEL')
    bevel.width = .004
    bevel.segments = 2
    ob.modifiers.new('Weighted normals', 'WEIGHTED_NORMAL')

bpy.context.view_layer.update()
for ob in bpy.context.scene.objects:
    ob.matrix_world = Matrix.Rotation(math.pi/2, 4, 'X') @ ob.matrix_world
bpy.ops.object.select_all(action='SELECT')
path = ROOT/'assets/models/knives/steak.glb'
bpy.ops.export_scene.gltf(filepath=str(path), export_format='GLB', use_selection=True, export_apply=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(path))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/steak_knife.blend'))
