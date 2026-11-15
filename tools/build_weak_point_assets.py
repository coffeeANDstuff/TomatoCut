"""Original stitched Giant seam; Blender source and GLB share event-region data.

Run: blender --background --python tools/build_weak_point_assets.py
Earlier fruit/fragment/equipment models are never rewritten.
"""
import json
import math
from pathlib import Path
import bpy
from mathutils import Matrix, Vector

ROOT = Path(__file__).resolve().parents[1]
event = next(d for d in json.loads((ROOT/'data/events.json').read_text()) if d['id'] == 'giant_harvest')
specimen, region = event['specimen'], event['weak_point']
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)


def shell(polar, azimuth):
    y = math.cos(polar)
    lobe = 1+specimen['proxy_lobe']*math.cos(specimen['proxy_lobe_count']*azimuth)*(1-y*y)
    taper = 1-specimen['proxy_taper']*y
    return Vector((math.sin(polar)*math.cos(azimuth)*specimen['proxy_axes'][0]*lobe*taper,
                   y*specimen['proxy_axes'][1],
                   math.sin(polar)*math.sin(azimuth)*specimen['proxy_axes'][2]*lobe*taper))


def surface(polar, azimuth):
    u = shell(polar+.001, azimuth)-shell(polar-.001, azimuth)
    v = shell(polar, azimuth+.001)-shell(polar, azimuth-.001)
    return shell(polar, azimuth)+v.cross(u).normalized()*region['surface_offset']


def material(name, color):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    nodes.clear()
    emission = nodes.new('ShaderNodeEmission')
    emission.inputs['Color'].default_value = (*color, 1)
    emission.inputs['Strength'].default_value = 1
    output = nodes.new('ShaderNodeOutputMaterial')
    mat.node_tree.links.new(emission.outputs[0], output.inputs['Surface'])
    return mat


def mesh(name, vertices, faces, mat):
    data = bpy.data.meshes.new(name)
    data.from_pydata(vertices, [], faces)
    data.update()
    ob = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(ob)
    ob.data.materials.append(mat)
    return ob


def ring(name, inner, outer, mat):
    vertices, faces = [], []
    segments = region['segments']
    for radius in [inner, outer]:
        for i in range(segments):
            angle = math.tau*i/segments
            vertices.append(surface(region['polar']+region['angular_radii'][0]*math.cos(angle)*radius,
                                    region['azimuth']+region['angular_radii'][1]*math.sin(angle)*radius))
    for i in range(segments):
        j = (i+1) % segments
        faces.append((i, j, j+segments, i+segments))
    return mesh(name, vertices, faces, mat)


ink = material('Seam dark ink', (.022, .048, .034))
cream = material('Seam ivory stitches', (.88, .79, .58))
ring('Visible seam boundary', .84, 1, ink)
ivory = ring('Ivory aiming stitch', .88, .96, cream)
# Four small inward stitches, not a floating cursor reticle. All vertices sit
# on the same authored ribbed skin and stay inside the collision boundary.
vertices, faces = [], []
for angle in [0, math.pi/2, math.pi, 3*math.pi/2]:
    start = len(vertices)
    for radius, offset in [(.48, -.035), (.82, -.035), (.82, .035), (.48, .035)]:
        vertices.append(surface(region['polar']+region['angular_radii'][0]*math.cos(angle+offset)*radius,
                                region['azimuth']+region['angular_radii'][1]*math.sin(angle+offset)*radius))
    faces.append(tuple(range(start, start+4)))
stitches = mesh('Four short seam stitches', vertices, faces, cream)
bpy.ops.object.select_all(action='DESELECT')
ivory.select_set(True)
stitches.select_set(True)
bpy.context.view_layer.objects.active = ivory
bpy.ops.object.join()
# Match the established Godot-axis export convention; source retains the
# authored geometry before this scene transform.
for ob in bpy.context.scene.objects:
    ob.matrix_world = Matrix.Rotation(math.pi/2, 4, 'X') @ ob.matrix_world
    if ob.type == 'MESH':
        for polygon in ob.data.polygons:
            polygon.use_smooth = True
path = ROOT/'assets/models/events/giant_weak_point.glb'
path.parent.mkdir(parents=True, exist_ok=True)
bpy.ops.export_scene.gltf(filepath=str(path), export_format='GLB', export_yup=True)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/giant_weak_point.blend'))
print('Original Giant aiming seam: two material meshes, event-data geometry, Blender/GLB saved')
