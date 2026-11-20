"""Original tall five-shouldered Big Boy, stout four-chamber prepared interior."""
from pathlib import Path
import json,math,sys,bpy
sys.path.insert(0,str(Path(__file__).resolve().parent))
from blender_meshes import ROOT,clear,material,mesh,sphere,clip,export
DATA=next(d for d in json.loads((ROOT/'data/tomatoes.json').read_text()) if d['id']=='big_boy')
AXES=DATA['proxy_axes'];clear()
skin=material('Big Boy deep ruby skin',(.44,.022,.016),.46)
flesh=material('Big Boy firm orange-red flesh',(.68,.16,.080),.39)
pith=material('Big Boy thick peach pith',(.88,.59,.34),.51)
gel=material('Big Boy four claret locules',(.23,.022,.020),.28)
seed=material('Big Boy broad cream seeds',(.93,.80,.57),.44)
green=material('Big Boy upright forest calyx',(.070,.14,.045),.72)
scar=material('Big Boy corked poles',(.19,.105,.045),.78)
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
   point=(math.cos(a),math.sin(a)*math.cos(t),math.sin(a)*math.sin(t)) if half else (math.sin(a)*math.cos(t),math.cos(a),math.sin(a)*math.sin(t))
   vertices.append(shape(*point))
 for i in range(rings):
  for j in range(segments):
   a=i*segments+j;b=i*segments+(j+1)%segments
   face=(a,b,b+segments,a+segments);faces.append(tuple(reversed(face)) if half else face)
 mesh('Prepared Big Boy half' if half else 'Tall five-shouldered Big Boy globe',vertices,faces,skin)
def crown():
 sphere('Wide Big Boy top scar',(0,AXES[1]-.004,0),(.17,.018,.16),scar,24,10)
 sphere('Small Big Boy blossom scar',(0,-AXES[1]+.008,0),(.080,.012,.072),scar,20,8)
 for j in range(6):
  t=math.tau*j/6
  points=[(0,AXES[1],0),(.16*math.cos(t-.35),AXES[1]+.04,.16*math.sin(t-.35)),(.33*math.cos(t),AXES[1]+.14,.33*math.sin(t)),(.16*math.cos(t+.35),AXES[1]+.04,.16*math.sin(t+.35)),(.16*math.cos(t),AXES[1]+.10,.16*math.sin(t))]
  ob=mesh('Upright folded six-point Big Boy calyx',points,[(0,1,4),(1,2,4),(2,3,4),(3,0,4)],green)
  mod=ob.modifiers.new('Calyx substance','SOLIDIFY');mod.thickness=.016
 for j in range(10):
  t=j/9;sphere('Bent Big Boy stem',(.065*math.sin(t*1.8),AXES[1]+.025+.26*t,-.025*t*t),(.035,.038,.035),green)
def half():
 shell(True)
 rim=[(-.004,*shape(0,math.cos(math.tau*j/60),math.sin(math.tau*j/60))[1:]) for j in range(60)]
 mesh('Stout four-chamber Big Boy flesh',[(-.004,0,0)]+rim,[(0,(j+1)%60+1,j+1) for j in range(60)],flesh,False)
 sphere('Reinforced Big Boy central core',(-.018,0,0),(.015,.23,.20),pith,24,12)
 for j in range(4):
  t=math.pi/4+math.tau*j/4
  cy,cz=.49*math.cos(t),.49*math.sin(t)
  ob=sphere('Four stout Big Boy seed chambers',(-.016,cy,cz),(.014,.23,.17),gel,24,12);ob.rotation_euler.x=t
  for k in range(6):
   a=math.tau*k/6
   ob=sphere('Big Boy plump individually modeled seed',(-.035,cy+.14*math.cos(a),cz+.10*math.sin(a)),(.012,.037,.022),seed)
   ob.rotation_euler.x=a+t
 for j in range(4):
  t=math.tau*j/4
  points=[(-.021,ry*math.cos(t+a),rz*math.sin(t+a)) for ry,rz,a in [(.17,.17,-.19),(.71,.65,-.045),(.71,.65,.045),(.17,.17,.19)]]
  mesh('Thick four-way Big Boy septum',points,[(0,1,2,3)],pith,False)
shell();crown();export('assets/models/tomatoes/big_boy.glb')
half();export('assets/models/fragments/big_boy_half.glb')
half();clip((0,1,0),flesh,'Prepared Big Boy half');export('assets/models/fragments/big_boy_wedge.glb')
half();clip((0,1,0),flesh,'Prepared Big Boy half');clip((1,-1,0),flesh,'Prepared Big Boy half')
ob=sphere('Fresh Big Boy diagonal chamber',(.22,.22,0),(.012,.16,.25),gel,24,12);ob.rotation_euler.z=-math.pi/4
for z in [-.16,0,.16]:
 ob=sphere('Fresh Big Boy diagonal seed',(.208,.232,z),(.013,.034,.022),seed);ob.rotation_euler.z=-math.pi/4
export('assets/models/fragments/big_boy_chunk.glb')
for path in ['assets/models/tomatoes/big_boy.glb']+['assets/models/fragments/big_boy_'+kind+'.glb' for kind in ['half','wedge','chunk']]:bpy.ops.import_scene.gltf(filepath=str(ROOT/path))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/big_boy.blend'))
