"""Small Blender-only helpers for new original assets; no scene side effects."""
from pathlib import Path
import math
import bpy
import bmesh
from mathutils import Matrix, Vector
from mathutils.geometry import convex_hull_2d

ROOT = Path(__file__).resolve().parents[1]


def clear():
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


def mesh(name, vertices, faces, mat, smooth=True):
    data = bpy.data.meshes.new(name)
    data.from_pydata(vertices, [], faces)
    data.update()
    ob = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(ob)
    ob.data.materials.append(mat)
    for face in data.polygons:
        face.use_smooth = smooth
    return ob


def sphere(name, center, size, mat, segments=16, rings=8):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=center)
    ob = bpy.context.object
    ob.name = name
    ob.scale = size
    ob.data.materials.append(mat)
    for face in ob.data.polygons:
        face.use_smooth = True
    return ob


def prism(name, outline, depth, z, mat, bevel=.007):
    n = len(outline)
    ob = mesh(name, [(x, y, z+side*depth) for side in [-1, 1] for x, y in outline],
              [tuple(range(n-1, -1, -1)), tuple(range(n, 2*n))]+
              [(i, (i+1) % n, (i+1) % n+n, i+n) for i in range(n)], mat, False)
    if bevel:
        mod = ob.modifiers.new('Hand-finished edge chamfers', 'BEVEL')
        mod.width = bevel
        mod.segments = 3
    ob.modifiers.new('Weighted surface normals', 'WEIGHTED_NORMAL')
    return ob


def clip(normal, flesh, shell_prefix):
    """Keep the positive half-plane and author outward flesh on new cut faces."""
    bpy.context.view_layer.update()
    n = Vector(normal).normalized()
    u = n.cross(Vector((0, 0, 1)))
    if u.length < .001:
        u = n.cross(Vector((0, 1, 0)))
    u.normalize()
    v = n.cross(u)
    for ob in list(bpy.context.scene.objects):
        ob.data.transform(ob.matrix_world)
        ob.matrix_world = Matrix.Identity(4)
        bm = bmesh.new()
        bm.from_mesh(ob.data)
        bmesh.ops.remove_doubles(bm, verts=list(bm.verts), dist=.00001)
        bmesh.ops.bisect_plane(bm, geom=list(bm.verts)+list(bm.edges)+list(bm.faces),
                              plane_co=(0, 0, 0), plane_no=n, dist=.00001, clear_inner=True)
        cut = [vertex for vertex in bm.verts if abs(vertex.co.dot(n)) < .0001]
        if len(cut) >= 3:
            hull = convex_hull_2d([Vector((vertex.co.dot(u), vertex.co.dot(v))) for vertex in cut])
            if len(hull) >= 3:
                try:
                    face = bm.faces.new([cut[i] for i in hull])
                    ob.data.materials.append(flesh)
                    face.material_index = len(ob.data.materials)-1
                    face.normal_update()
                    if face.normal.dot(n) > 0:
                        face.normal_flip()
                except ValueError:
                    pass  # An existing coplanar face already closes this object.
        bm.normal_update()
        if ob.name.startswith(shell_prefix):
            assert any(f.normal.dot(n) < -.99 and f.calc_area() > .01 and all(abs(vertex.co.dot(n)) < .0001 for vertex in f.verts) for f in bm.faces), 'Missing outward flesh cap: '+ob.name
        bm.to_mesh(ob.data)
        bm.free()
        ob.data.update()
        if not ob.data.polygons:
            bpy.data.objects.remove(ob, do_unlink=True)


def export(relative):
    """Bake modifiers, preserve evaluated geometry, batch materials, export GLB."""
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
    assert sum(len(ob.data.vertices) for ob in bpy.context.scene.objects) == count, 'Batching changed evaluated geometry'
    assert len(bpy.context.scene.objects) <= 8, 'Material-node budget exceeded'
    print('BATCHED ASSET:', relative, len(bpy.context.scene.objects), 'mesh nodes;', count, 'vertices')
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.gltf(filepath=str(ROOT/relative), export_format='GLB', use_selection=True, export_apply=True)
    clear()
