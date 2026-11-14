"""Original Honing Kit study. Blender 4.3.2; preserves earlier art sources."""
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


wood = material('Oiled walnut cradle', (.16, .075, .033), .65)
stone = material('Fine sage honing stone', (.19, .25, .22), .91)
coarse = material('Coarse charcoal stone layer', (.085, .11, .10), .96)
groove = material('Quiet engraved grain', (.13, .18, .15), .98)
brass = material('Small aged brass fittings', (.35, .24, .09), .42, .65)


def box(name, at, scale, mat, bevel):
    bpy.ops.mesh.primitive_cube_add(location=at)
    ob = bpy.context.object
    ob.name = name
    ob.scale = scale
    ob.data.materials.append(mat)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    edge = ob.modifiers.new('Soft crafted edges', 'BEVEL')
    edge.width = bevel
    edge.segments = 3
    ob.modifiers.new('Weighted normals', 'WEIGHTED_NORMAL')
    return ob


box('Walnut stone cradle', (0, 0, -.065), (.88, .32, .075), wood, .065)
box('Charcoal coarse layer', (0, 0, .045), (.70, .245, .055), coarse, .023)
box('Fine sage honing face', (0, 0, .13), (.70, .245, .045), stone, .022)
for x in [-.78, .78]:
    box('Raised cradle end', (x, 0, .035), (.055, .28, .055), wood, .026)
    box('Brass cradle pin', (x, 0, .095), (.018, .048, .009), brass, .007)
for x in [-.48, -.24, 0, .24, .48]:
    ob = box('Fine engraved stone stroke', (x, 0, .175), (.003, .16, .001), groove, .001)
    ob.rotation_euler.z = -.18
for x in [-.57, .57]:
    for y in [-.23, .23]:
        box('Brass underside foot', (x, y, -.16), (.055, .045, .024), brass, .015)

bpy.context.view_layer.update()
for ob in bpy.context.scene.objects:
    ob.matrix_world = Matrix.Rotation(math.pi/2, 4, 'X') @ ob.matrix_world
bpy.ops.object.select_all(action='SELECT')
path = ROOT/'assets/models/equipment/honing_kit.glb'
path.parent.mkdir(parents=True, exist_ok=True)
bpy.ops.export_scene.gltf(filepath=str(path), export_format='GLB', use_selection=True, export_apply=True)
# Save the exact exported geometry as an editable Blender source.
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(path))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/honing_kit.blend'))
