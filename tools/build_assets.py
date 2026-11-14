"""Run: blender --background --python tools/build_assets.py (Blender 4.3+)."""
import bpy, bmesh, math, random, sys
from pathlib import Path
from mathutils import Vector, Matrix
from mathutils.geometry import convex_hull_2d
ROOT = Path(__file__).resolve().parents[1]
CHERRY = "--cherry" in sys.argv
ROMA = "--roma" in sys.argv
GOLDEN = "--golden" in sys.argv
AXES = (.62,.60,.52) if GOLDEN else ((.40,.78,.40) if ROMA else ((.54,.60,.54) if CHERRY else (.6,.53,.53)))
LOBE = .085 if GOLDEN else (.012 if ROMA else (.008 if CHERRY else .045))
TAPER = .08 if GOLDEN else (.15 if ROMA else 0.0)
LOBES = 7 if GOLDEN else 5
random.seed(431)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)

def mat(name, color, rough=.4, metal=0):
 m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
 bs=m.node_tree.nodes.get('Principled BSDF'); bs.inputs['Base Color'].default_value=(*color,1); bs.inputs['Roughness'].default_value=rough; bs.inputs['Metallic'].default_value=metal

 return m
skin=mat('Tomato skin',(.64,.028,.012),.3); flesh=mat('Moist cut flesh',(.93,.17,.09),.28); core=mat('Pale core',(.98,.47,.23),.42); chamber=mat('Seed chamber',(.38,.035,.018),.2); seed=mat('Cream seeds',(.99,.78,.37),.32); green=mat('Botanical calyx',(.10,.22,.055),.65); steel=mat('Worn brushed steel',(.46,.49,.45),.48,.72); wood=mat('Dark walnut',(.12,.055,.025),.6); brass=mat('Old brass rivets',(.47,.29,.10),.38,.65)

if GOLDEN:
 skin=mat('Warm luminous golden skin',(.47,.29,.085),.35,.45)
 shader=skin.node_tree.nodes['Principled BSDF']
 shader.inputs['Emission Color'].default_value=(.12,.07,.01,1)
 shader.inputs['Emission Strength'].default_value=.25
 flesh=mat('Amber golden cut flesh',(.50,.20,.035),.45)
 core=mat('Honey pale core',(.72,.54,.23),.43)
 chamber=mat('Seven amber seed chambers',(.18,.07,.015),.30)
 seed=mat('Ivory event seeds',(.80,.72,.48),.37)
 green=mat('Bronzed seven-leaf crown',(.18,.20,.055),.52,.22)

if CHERRY:
 skin.diffuse_color=(.58,.016,.009,1); skin.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value=skin.diffuse_color
 flesh.diffuse_color=(.82,.11,.08,1); flesh.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value=flesh.diffuse_color

if ROMA:
 skin.diffuse_color=(.58,.025,.01,1); skin.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value=skin.diffuse_color
 flesh.diffuse_color=(.84,.12,.075,1); flesh.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value=flesh.diffuse_color

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
   lobe=1+LOBE*math.cos(LOBES*math.atan2(z,x))*(1-y*y)
   taper=1-TAPER*y
   vs.append((x*AXES[0]*lobe*taper,y*AXES[1],z*AXES[2]*lobe*taper))
 for i in range(rings):
  for j in range(segs):
   a=i*segs+j; b=i*segs+(j+1)%segs
   fs.append((a,b,b+segs,a+segs))
 return mesh('Prepared right half' if half else ('Golden seven-lobe specimen' if GOLDEN else ('Roma' if ROMA else ('Cherry' if CHERRY else 'Standard Red'))),vs,[tuple(reversed(f)) for f in fs] if half else fs,skin)

def crown():
 count=7 if GOLDEN else (4 if CHERRY else (3 if ROMA else 5))
 for j in range(count):
  t=math.tau*j/count
  top=AXES[1]
  length=.26 if ROMA else (.30 if CHERRY else .39)
  vs=[(0,top-.015,0),(.10*math.cos(t-.6),top+.01,.10*math.sin(t-.6)),(length*math.cos(t),top-.10,length*math.sin(t)),(.10*math.cos(t+.6),top+.01,.10*math.sin(t+.6))]
  ob=mesh('Calyx leaf',vs,[(0,1,2,3)],green); so=ob.modifiers.new('Leaf thickness','SOLIDIFY'); so.thickness=.018
 if GOLDEN:
  # Curved segmented stem rises from the seven-point event crown.
  for i in range(9):
   t=i/8
   sphere('Curled event stem',(.095*t*t,AXES[1]+.03+.20*t,.025*math.sin(t*math.pi)),(.033,.041,.033),green)
 else:
  sphere('Stem',(0,.88 if ROMA else (.70 if CHERRY else .61),0),(.035,.12,.035) if ROMA else ((.035,.17,.035) if CHERRY else (.046,.15,.046)),green)

def export(name):
 if GOLDEN:
  name=name.replace('assets/models/tomatoes/standard_red.glb','assets/models/events/golden.glb').replace('standard_','event_golden_')
 if CHERRY or ROMA:
  prefix='roma' if ROMA else 'cherry'
  name=name.replace('standard_red.glb',prefix+'.glb').replace('standard_',prefix+'_')
 bpy.context.view_layer.update()
 for ob in list(bpy.context.scene.objects):
  ob.matrix_world = Matrix.Rotation(math.pi / 2, 4, 'X') @ ob.matrix_world
 bpy.ops.object.select_all(action='SELECT')
 (ROOT/name).parent.mkdir(parents=True,exist_ok=True)
 bpy.ops.export_scene.gltf(filepath=str(ROOT/name),export_format='GLB',use_selection=True,export_apply=True)
 bpy.ops.object.delete(use_global=False)

fruit_surface(); crown(); export('assets/models/tomatoes/standard_red.glb')
def prepared_half():
 fruit_surface(True)
 # The cap is a seed-filled flesh disk on the x=0 plane. The prepared half exposes it during tumble.
 vs=[(-.003,0,0)]+[(-.003,AXES[1]*math.cos(i*math.tau/48),AXES[2]*math.sin(i*math.tau/48)*(1-TAPER*math.cos(i*math.tau/48))) for i in range(48)]
 mesh('Cut flesh',vs,[(0,(i+1)%48+1,i+1) for i in range(48)],flesh)
 sphere('Pale central core',(-.014,0,0),(.015,.19,.19),core)
 for j in range(7 if GOLDEN else (2 if ROMA else (3 if CHERRY else 5))):
  t=math.tau*j/(7 if GOLDEN else (2 if ROMA else (3 if CHERRY else 5)))
  y=(.40 if ROMA else .30)*math.cos(t); z=(.22 if ROMA else .30)*math.sin(t)
  ob=sphere('Seed chamber',(-.012,y,z),(.013,.18,.09) if ROMA else (.013,.12,.085),chamber); ob.rotation_euler.x=t
  for k in range(4):
   a=t+(k-1.5)*.25
   ob=sphere('Seed',(-.029,(.40 if ROMA else .30)*math.cos(a),(.22 if ROMA else .30)*math.sin(a)),(.012,.033,.018),seed); ob.rotation_euler.x=a

def clip_fragment(normal):
 # Apply object transforms before clipping, keeping the pre-export Godot axes.
 bpy.context.view_layer.update()
 for ob in list(bpy.context.scene.objects):
  if ob.type != 'MESH': continue
  ob.data.transform(ob.matrix_world); ob.matrix_world=Matrix.Identity(4)
  bm=bmesh.new(); bm.from_mesh(ob.data)
  bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=0.00001)
  result=bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=0.00001,plane_co=(0,0,0),plane_no=normal,clear_inner=True)
  # The skin's original x=0 rim is deliberately open (a separate flesh disk
  # closes it). A bisected rim is an arc, not an edge loop, so holes_fill alone
  # cannot cap it. Build a planar convex cap including the closing chord.
  n=Vector(normal).normalized()
  u=n.cross(Vector((0,0,1)))
  if u.length < 0.001: u=n.cross(Vector((0,1,0)))
  u.normalize(); v=n.cross(u)
  cut=[vertex for vertex in bm.verts if abs(vertex.co.dot(n)) < 0.0001]
  if len(cut)>=3:
   hull=convex_hull_2d([Vector((vertex.co.dot(u),vertex.co.dot(v))) for vertex in cut])
   if len(hull)>=3:
    try:
     face=bm.faces.new([cut[i] for i in hull])
     ob.data.materials.append(flesh); face.material_index=len(ob.data.materials)-1; face.smooth=False
     face.normal_update()
     if face.normal.dot(n)>0: face.normal_flip()
    except ValueError: pass # Coplanar existing face already closes this object.
  bm.normal_update()
  if ob.name.startswith('Prepared right half'):
   assert any(f.normal.dot(n)<-0.99 and f.calc_area()>0.01 and all(abs(vertex.co.dot(n))<0.0001 for vertex in f.verts) for f in bm.faces), 'Missing outward flesh cap on '+ob.name
  bm.to_mesh(ob.data); bm.free(); ob.data.update()
  if not ob.data.polygons: bpy.data.objects.remove(ob,do_unlink=True)

prepared_half()
export('assets/models/fragments/standard_half.glb')
# Quarter wedges and eighth chunks retain the original flesh/chambers/seeds.
prepared_half(); clip_fragment((0,1,0)); export('assets/models/fragments/standard_wedge.glb')
prepared_half(); clip_fragment((0,1,0)); clip_fragment((1,-1,0))
# The final diagonal cut exposes a fresh moist chamber, not a featureless cap.
ob=sphere('Eighth seed chamber',(.174,.186,0),(.009,.09,.17),chamber); ob.rotation_euler.z=-math.pi/4
for z in [-.095,.095]:
 ob=sphere('Eighth seed',(.164,.196,z),(.012,.032,.018),seed); ob.rotation_euler.z=-math.pi/4
export('assets/models/fragments/standard_chunk.glb')
if not CHERRY and not ROMA and not GOLDEN:
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
# Save all five integrated models together for source inspection.
paths=['assets/models/tomatoes/standard_red.glb','assets/models/fragments/standard_half.glb','assets/models/fragments/standard_wedge.glb','assets/models/fragments/standard_chunk.glb','assets/models/knives/rusty_butter.glb']
if CHERRY or ROMA:
 prefix='roma' if ROMA else 'cherry'
 paths=[path.replace('standard_red.glb',prefix+'.glb').replace('standard_',prefix+'_') for path in paths if '/knives/' not in path]
if GOLDEN:
 paths=[path.replace('assets/models/tomatoes/standard_red.glb','assets/models/events/golden.glb').replace('standard_','event_golden_') for path in paths if '/knives/' not in path]
for path in paths:
 bpy.ops.import_scene.gltf(filepath=str(ROOT/path))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/('art/golden_harvest.blend' if GOLDEN else ('art/roma.blend' if ROMA else ('art/cherry.blend' if CHERRY else 'art/vertical_slice.blend')))))
