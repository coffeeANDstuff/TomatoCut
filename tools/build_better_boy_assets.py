"""Original broad six-shouldered premium Better Boy with five amber seed locules."""
from pathlib import Path
import json,math,sys,bpy
sys.path.insert(0,str(Path(__file__).resolve().parent))
from blender_meshes import ROOT,clear,material,mesh,sphere,clip,export
DATA=next(d for d in json.loads((ROOT/'data/tomatoes.json').read_text()) if d['id']=='better_boy')
AXES=DATA['proxy_axes'];clear()
skin=material('Better Boy warm vermilion skin',(.53,.042,.018),.40)
flesh=material('Better Boy dense copper-red flesh',(.69,.20,.095),.36)
pith=material('Better Boy peach pentagonal pith',(.88,.61,.35),.48)
gel=material('Better Boy five olive-amber seed pockets',(.33,.17,.042),.26)
seed=material('Better Boy long ivory seeds',(.94,.81,.54),.42)
green=material('Better Boy curled sage crown',(.12,.20,.066),.69)
scar=material('Better Boy recessed stem scar',(.24,.12,.039),.77)
def shape(x,y,z):
 lobe=1+DATA['proxy_lobe']*math.cos(DATA['proxy_lobe_count']*math.atan2(z,x))*(1-y*y)
 taper=1-DATA['proxy_taper']*y
 return (x*AXES[0]*lobe*taper,y*AXES[1],z*AXES[2]*lobe*taper)
def shell(half=False):
 vertices=[];faces=[];rings=28;segments=60
 for i in range(rings+1):
  a=math.pi*(.5 if half else 1)*i/rings
  for j in range(segments):
   t=math.tau*j/segments
   v=(math.cos(a),math.sin(a)*math.cos(t),math.sin(a)*math.sin(t)) if half else (math.sin(a)*math.cos(t),math.cos(a),math.sin(a)*math.sin(t))
   vertices.append(shape(*v))
 for i in range(rings):
  for j in range(segments):
   a=i*segments+j;b=i*segments+(j+1)%segments;f=(a,b,b+segments,a+segments);faces.append(tuple(reversed(f)) if half else f)
 mesh('Prepared Better Boy half' if half else 'Broad six-shouldered Better Boy',vertices,faces,skin)
def crown():
 sphere('Depressed Better Boy stem scar',(0,AXES[1]-.008,0),(.16,.017,.14),scar,24,10)
 sphere('Better Boy small blossom scar',(0,-AXES[1]+.006,0),(.054,.010,.047),scar,16,8)
 for j in range(7):
  t=math.tau*j/7;points=[]
  for r,h,w in [(0,0,0),(.14,.035,-.32),(.29,-.035,-.15),(.40,.055,0),(.25,.07,.20),(.13,.035,.32)]:
   points.append((r*math.cos(t+w),AXES[1]+h,r*math.sin(t+w)))
  ob=mesh('Seven curled Better Boy calyx blades',points,[(0,1,4,5),(1,2,3,4)],green)
  mod=ob.modifiers.new('Fine curled calyx substance','SOLIDIFY');mod.thickness=.013
 for j in range(10):
  t=j/9;sphere('Crooked low Better Boy stem',(.075*t,AXES[1]+.015+.18*t,-.045*math.sin(t*math.pi)),(.029,.031,.029),green)
def half():
 shell(True)
 rim=[(-.004,*shape(0,math.cos(math.tau*j/60),math.sin(math.tau*j/60))[1:]) for j in range(60)]
 mesh('Five-chamber Better Boy copper flesh',[(-.004,0,0)]+rim,[(0,(j+1)%60+1,j+1) for j in range(60)],flesh,False)
 core=[(-.020,.145*math.cos(math.tau*j/5),.15*math.sin(math.tau*j/5)) for j in range(5)]
 mesh('Better Boy pentagonal pale core',core,[tuple(range(4,-1,-1))],pith,False)
 for j in range(5):
  t=math.tau*j/5
  cy,cz=.39*math.cos(t),.42*math.sin(t)
  ob=sphere('Five full Better Boy amber locules',(-.016,cy,cz),(.013,.145,.17),gel,24,12);ob.rotation_euler.x=t
  for k in range(5):
   a=math.tau*k/5
   ob=sphere('Individually modeled Better Boy cream seed',(-.034,cy+.090*math.cos(a),cz+.110*math.sin(a)),(.012,.035,.018),seed);ob.rotation_euler.x=a+t
  t+=math.pi/5
  pts=[(-.020,ry*math.cos(t+a),rz*math.sin(t+a)) for ry,rz,a in [(.13,.14,-.14),(.53,.58,-.025),(.53,.58,.025),(.13,.14,.14)]]
  mesh('Five radial Better Boy septa',pts,[(0,1,2,3)],pith,False)
shell();crown();export('assets/models/tomatoes/better_boy.glb')
half();export('assets/models/fragments/better_boy_half.glb')
half();clip((0,1,0),flesh,'Prepared Better Boy half');export('assets/models/fragments/better_boy_wedge.glb')
half();clip((0,1,0),flesh,'Prepared Better Boy half');clip((1,-1,0),flesh,'Prepared Better Boy half')
ob=sphere('Fresh Better Boy diagonal gel',(.20,.20,0),(.012,.13,.22),gel,24,12);ob.rotation_euler.z=-math.pi/4
for z in [-.13,0,.13]:
 ob=sphere('Fresh Better Boy diagonal seed',(.188,.212,z),(.012,.032,.019),seed);ob.rotation_euler.z=-math.pi/4
export('assets/models/fragments/better_boy_chunk.glb')
for path in ['assets/models/tomatoes/better_boy.glb']+['assets/models/fragments/better_boy_'+k+'.glb' for k in ['half','wedge','chunk']]:bpy.ops.import_scene.gltf(filepath=str(ROOT/path))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/better_boy.blend'))
