"""Run: blender --background --python tools/build_assets.py (Blender 4.3+)."""
import bpy, math, random
from pathlib import Path
from mathutils import Vector, Matrix
ROOT = Path(__file__).resolve().parents[1]
random.seed(431)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)

def mat(name, color, rough=.4, metal=0):
 m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
 bs=m.node_tree.nodes.get('Principled BSDF'); bs.inputs['Base Color'].default_value=(*color,1); bs.inputs['Roughness'].default_value=rough; bs.inputs['Metallic'].default_value=metal

 return m
skin=mat('Tomato skin',(.64,.028,.012),.3); flesh=mat('Moist cut flesh',(.93,.17,.09),.28); core=mat('Pale core',(.98,.47,.23),.42); chamber=mat('Seed chamber',(.38,.035,.018),.2); seed=mat('Cream seeds',(.99,.78,.37),.32); green=mat('Botanical calyx',(.10,.22,.055),.65); steel=mat('Worn brushed steel',(.46,.49,.45),.48,.72); wood=mat('Dark walnut',(.12,.055,.025),.6); brass=mat('Old brass rivets',(.47,.29,.10),.38,.65)

def mesh(name,verts,faces,material):
 me=bpy.data.meshes.new(name); me.from_pydata(verts,[],faces); me.update(); ob=bpy.data.objects.new(name,me); bpy.context.collection.objects.link(ob); ob.data.materials.append(material)
 for f in me.polygons: f.use_smooth=True
 return ob

def sphere(name,loc,scale,material):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=8,location=loc); ob=bpy.context.object; ob.name=name; ob.scale=scale; ob.data.materials.append(material)
 for f in ob.data.polygons: f.use_smooth=True
 return ob

def fruit_surface(half=False):
 vs=[]; fs=[]; rings=24; segs=48
 for i in range(rings+1):
  a=math.pi*i/rings if not half else math.pi*.5*i/rings
  for j in range(segs):
   t=math.tau*j/segs
   if half: x=math.cos(a); y=math.sin(a)*math.cos(t); z=math.sin(a)*math.sin(t)
   else: x=math.sin(a)*math.cos(t); y=math.cos(a); z=math.sin(a)*math.sin(t)
   lobe=1+.045*math.cos(5*math.atan2(z,x))*(1-y*y)
   vs.append((x*.6*lobe,y*.53,z*.53*lobe))
 for i in range(rings):
  for j in range(segs):
   a=i*segs+j; b=i*segs+(j+1)%segs
   fs.append((a,b,b+segs,a+segs))
 return mesh('Prepared right half' if half else 'Standard Red',vs,[tuple(reversed(f)) for f in fs] if half else fs,skin)

def crown():
 for j in range(5):
  t=math.tau*j/5
  vs=[(0,.515,0),(.10*math.cos(t-.6),.54,.10*math.sin(t-.6)),(.39*math.cos(t),.43,.39*math.sin(t)),(.10*math.cos(t+.6),.54,.10*math.sin(t+.6))]
  ob=mesh('Calyx leaf',vs,[(0,1,2,3)],green); so=ob.modifiers.new('Leaf thickness','SOLIDIFY'); so.thickness=.018
 sphere('Stem',(0,.61,0),(.046,.15,.046),green)

def export(name):
 bpy.context.view_layer.update()
 for ob in list(bpy.context.scene.objects):
  ob.matrix_world = Matrix.Rotation(math.pi / 2, 4, 'X') @ ob.matrix_world
 bpy.ops.object.select_all(action='SELECT')
 bpy.ops.export_scene.gltf(filepath=str(ROOT/name),export_format='GLB',use_selection=True,export_apply=True)
 bpy.ops.object.delete(use_global=False)

fruit_surface(); crown(); export('assets/models/tomatoes/standard_red.glb')
fruit_surface(True)
# The cap is a seed-filled flesh disk on the x=0 plane. The prepared half exposes it during tumble.
vs=[(-.003,0,0)]+[(-.003,.53*math.cos(i*math.tau/48),.53*math.sin(i*math.tau/48)) for i in range(48)]
mesh('Cut flesh',vs,[(0,(i+1)%48+1,i+1) for i in range(48)],flesh)
sphere('Pale central core',(-.014,0,0),(.015,.19,.19),core)
for j in range(5):
 t=math.tau*j/5
 y=.30*math.cos(t); z=.30*math.sin(t)
 ob=sphere('Seed chamber',(-.012,y,z),(.013,.12,.085),chamber); ob.rotation_euler.x=t
 for k in range(4):
  a=t+(k-1.5)*.25
  ob=sphere('Seed',(-.029,.30*math.cos(a),.30*math.sin(a)),(.012,.033,.018),seed); ob.rotation_euler.x=a
export('assets/models/fragments/standard_half.glb')
# Blunt butter blade: actual prism, matching local edge endpoints used by KnifeController.
outline=[(-.08,-.10),(.70,-.10),(.85,-.035),(.87,.035),(.79,.115),(.59,.15),(-.08,.12)]
vs=[(x,y,z) for z in [-.025,.025] for x,y in outline]; n=len(outline)
faces=[tuple(range(n-1,-1,-1)),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
ob=mesh('Rusty butter blade',vs,faces,steel); bevel=ob.modifiers.new('Soft worn edge','BEVEL'); bevel.width=.018; bevel.segments=3; ob.modifiers.new('Normals','WEIGHTED_NORMAL')
bpy.ops.mesh.primitive_cube_add(location=(-.48,.015,0)); ob=bpy.context.object; ob.name='Walnut handle'; ob.scale=(.40,.12,.065); ob.data.materials.append(wood); bpy.ops.object.transform_apply(location=False,rotation=False,scale=True); mod=ob.modifiers.new('Rounded grip','BEVEL'); mod.width=.065; mod.segments=4; ob.modifiers.new('Normals','WEIGHTED_NORMAL')
for x in [-.7,-.3]: sphere('Brass pin',(x,.015,.067),(.025,.025,.012),brass)
# Small oxidized pits, deliberately sparse.
for i in range(12): sphere('Patina',(random.uniform(.02,.66),random.uniform(-.065,.08),.027),(.018,.009,.002),wood)
export('assets/models/knives/rusty_butter.glb')
# Save the complete source scene for inspection, with the three exported objects imported in separate collections.
for path in ['assets/models/tomatoes/standard_red.glb','assets/models/fragments/standard_half.glb','assets/models/knives/rusty_butter.glb']:
 bpy.ops.import_scene.gltf(filepath=str(ROOT/path))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/vertical_slice.blend'))
