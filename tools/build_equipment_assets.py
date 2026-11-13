"""Original picnic knife. Run with Blender 4.3.2; leaves all prior GLBs intact."""
from pathlib import Path
import bpy, math
from mathutils import Matrix
ROOT = Path(__file__).resolve().parents[1]
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)


def material(name, color, roughness):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    shader = m.node_tree.nodes['Principled BSDF']
    shader.inputs['Base Color'].default_value = m.diffuse_color
    shader.inputs['Roughness'].default_value = roughness
    return m


ivory = material('Warm ivory molded plastic', (.79, .76, .63), .48)
sage = material('Sage grip inlay', (.17, .25, .18), .67)
# XY coordinates are gameplay coordinates; the lower edge matches knives.json.
outline = [(-.08,-.10),(.88,-.10),(1.05,-.04),(1.075,.035),(.99,.135),(.82,.18),(-.08,.135)]
verts = [(x,y,z) for z in [-.018,.018] for x,y in outline]
n = len(outline)
faces = [tuple(range(n-1,-1,-1)),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
mesh = bpy.data.meshes.new('Picnic blade geometry')
mesh.from_pydata(verts, [], faces)
mesh.update()
blade = bpy.data.objects.new('Molded picnic blade', mesh)
bpy.context.collection.objects.link(blade)
blade.data.materials.append(ivory)
bevel = blade.modifiers.new('Soft molded rim', 'BEVEL'); bevel.width = .008; bevel.segments = 3
blade.modifiers.new('Weighted surface normals', 'WEIGHTED_NORMAL')


def rounded_box(name, at, scale, mat, bevel_width):
    bpy.ops.mesh.primitive_cube_add(location=at)
    ob = bpy.context.object; ob.name = name; ob.scale = scale
    ob.data.materials.append(mat)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel = ob.modifiers.new('Molded corners', 'BEVEL'); bevel.width = bevel_width; bevel.segments = 4
    ob.modifiers.new('Weighted surface normals', 'WEIGHTED_NORMAL')
    return ob


rounded_box('Rounded picnic handle', (-.49,.018,0), (.43,.125,.052), ivory, .075)
rounded_box('Recessed green grip', (-.49,.02,.053), (.31,.076,.006), sage, .036)
for x in [-.69,-.59,-.49,-.39,-.29]:
    rounded_box('Molded grip rib', (x,.02,.063), (.012,.067,.008), ivory, .006)
# A small open hanging loop, distinct from the starter's brass rivets.
bpy.ops.mesh.primitive_torus_add(major_segments=24, minor_segments=8, location=(-.83,.018,0), major_radius=.045, minor_radius=.014)
bpy.context.object.name = 'Molded hanging loop'
bpy.context.object.data.materials.append(sage)
bpy.context.view_layer.update()
for ob in bpy.context.scene.objects:
    ob.matrix_world = Matrix.Rotation(math.pi/2, 4, 'X') @ ob.matrix_world
bpy.ops.object.select_all(action='SELECT')
path = ROOT/'assets/models/knives/plastic_picnic.glb'
bpy.ops.export_scene.gltf(filepath=str(path), export_format='GLB', use_selection=True, export_apply=True)
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(path))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/picnic_knife.blend'))
