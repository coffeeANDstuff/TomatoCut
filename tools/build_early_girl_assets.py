"""Original compact Early Girl, swept four-leaf crown and three kidney locules."""
from pathlib import Path
import json,math,sys,bpy
sys.path.insert(0,str(Path(__file__).resolve().parent))
from blender_meshes import ROOT,clear,material,mesh,sphere,clip,export
DATA=next(d for d in json.loads((ROOT/'data/tomatoes.json').read_text()) if d['id']=='early_girl')
AXES=DATA['proxy_axes'];clear()
skin=material('Early Girl lively scarlet skin',(.48,.026,.016),.37)
flesh=material('Early Girl coral flesh',(.75,.24,.14),.38)
pith=material('Early Girl pale triangular core',(.90,.69,.42),.49)
gel=material('Early Girl three honey-olive galleries',(.40,.25,.055),.25)
seed=material('Early Girl small cream seeds',(.96,.85,.60),.45)
leaf=material('Early Girl swept forest calyx',(.055,.14,.035),.72)
scar=material('Early Girl small corked scars',(.24,.15,.065),.78)
def shape(x,y,z):
 lobe=1+DATA['proxy_lobe']*math.cos(DATA['proxy_lobe_count']*math.atan2(z,x))*(1-y*y)
 taper=1-DATA['proxy_taper']*y
 return (x*AXES[0]*lobe*taper,y*AXES[1],z*AXES[2]*lobe*taper)
def shell(half=False):
 vertices=[];faces=[];rings=26;segments=48
 for i in range(rings+1):
  a=math.pi*(.5 if half else 1)*i/rings
  for j in range(segments):
   t=math.tau*j/segments
   v=(math.cos(a),math.sin(a)*math.cos(t),math.sin(a)*math.sin(t)) if half else (math.sin(a)*math.cos(t),math.cos(a),math.sin(a)*math.sin(t))
   vertices.append(shape(*v))
 for i in range(rings):
  for j in range(segments):
   a=i*segments+j;b=i*segments+(j+1)%segments;f=(a,b,b+segments,a+segments);faces.append(tuple(reversed(f)) if half else f)
 mesh('Prepared Early Girl half' if half else 'Compact four-shouldered Early Girl',vertices,faces,skin)
def crown():
 sphere('Early Girl recessed crown socket',(0,AXES[1]-.008,0),(.115,.013,.10),scar,24,8)
 sphere('Early Girl corked blossom scar',(0,-AXES[1]+.004,0),(.036,.007,.034),scar,16,8)
 for j in range(4):
  t=math.tau*j/4+.25;points=[]
  for r,h,w in [(0,0,0),(.12,.035,-.23),(.26,.035,-.20),(.37,.11,.05),(.24,.095,.13),(.11,.048,.25)]:
   points.append((r*math.cos(t+w),AXES[1]+h,r*math.sin(t+w)))
  ob=mesh('Four narrow swept-back Early Girl leaves',points,[(0,1,4,5),(1,2,3,4)],leaf)
  mod=ob.modifiers.new('Fine Early Girl leaf substance','SOLIDIFY');mod.thickness=.010
  for k in range(4):
   r=.06+k*.055;sphere('Raised Early Girl leaf midrib',(r*math.cos(t),AXES[1]+.045+k*.011,r*math.sin(t)),(.012,.011,.012),leaf,8,4)
 for j in range(7):
  a=j/6;sphere('Short leaning Early Girl stem',(-.075*a,AXES[1]+.025+.15*a,.02*a),(.023,.027,.023),leaf,12,6)
def half():
 shell(True)
 rim=[(-.004,*shape(0,math.cos(math.tau*j/48),math.sin(math.tau*j/48))[1:]) for j in range(48)]
 mesh('Early Girl coral cut flesh',[(-.004,0,0)]+rim,[(0,(j+1)%48+1,j+1) for j in range(48)],flesh,False)
 core=[(-.025,.12*math.cos(math.tau*j/3),.115*math.sin(math.tau*j/3)) for j in range(3)]
 mesh('Early Girl triangular cream core',core,[(2,1,0)],pith,False)
 for j in range(3):
  angle=math.tau*j/3;points=[]
  # Two curved banks form a kidney-shaped wet seed gallery, not an ellipse.
  for side in [1,-1]:
   for k in range(17):
    a=(-.65+1.30*k/16) if side==1 else (.65-1.30*k/16)
    r=.34+side*.073*math.sin(math.pi*k/16)
    points.append((-.018,r*math.cos(angle+a),r*.94*math.sin(angle+a)))
  mesh('Three curved Early Girl seed galleries',points,[tuple(range(len(points)-1,-1,-1))],gel,False)
  for k in range(6):
   a=angle-.48+k*.19;r=.34+(.025 if k%2 else -.018)
   ob=sphere('Eighteen Early Girl cream seeds',(-.030,r*math.cos(a),r*.94*math.sin(a)),(.010,.026,.013),seed,12,6);ob.rotation_euler.x=a+.45
  a=angle+math.pi/3
  pts=[(-.023,r*math.cos(a+w),r*.94*math.sin(a+w)) for r,w in [(.10,-.12),(.48,-.025),(.48,.025),(.10,.12)]]
  mesh('Three narrow Early Girl septa',pts,[(0,1,2,3)],pith,False)
shell();crown();export('assets/models/tomatoes/early_girl.glb')
half();export('assets/models/fragments/early_girl_half.glb')
half();clip((0,1,0),flesh,'Prepared Early Girl half');export('assets/models/fragments/early_girl_wedge.glb')
half();clip((0,1,0),flesh,'Prepared Early Girl half');clip((1,-1,0),flesh,'Prepared Early Girl half')
ob=sphere('Fresh Early Girl diagonal gallery',(.15,.15,.05),(.010,.09,.15),gel,20,10);ob.rotation_euler.z=-math.pi/4
for z in [-.04,.04,.12]:
 ob=sphere('Fresh Early Girl diagonal cream seed',(.139,.161,z),(.009,.025,.014),seed,12,6);ob.rotation_euler.z=-math.pi/4
export('assets/models/fragments/early_girl_chunk.glb')
for path in ['assets/models/tomatoes/early_girl.glb']+['assets/models/fragments/early_girl_'+k+'.glb' for k in ['half','wedge','chunk']]:bpy.ops.import_scene.gltf(filepath=str(ROOT/path))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/early_girl.blend'))
