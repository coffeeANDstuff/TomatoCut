"""Original squared Nakiri, dark forged finish and octagonal walnut wa handle."""
from pathlib import Path
import json,math,sys,bpy
sys.path.insert(0,str(Path(__file__).resolve().parent))
from blender_meshes import ROOT,clear,material,mesh,prism,export
DATA=next(d for d in json.loads((ROOT/'data/knives.json').read_text()) if d['id']=='nakiri');clear()
steel=material('Nakiri brushed carbon steel',(.34,.40,.39),.52,.57)
hone=material('Nakiri wide satin honed facet',(.66,.72,.67),.49,.54)
forged=material('Nakiri charcoal forged shoulders',(.065,.085,.075),.74,.38)
walnut=material('Nakiri octagonal walnut wa grip',(.15,.078,.036),.66)
grain=material('Nakiri raised walnut grain',(.085,.042,.019),.73)
ferrule=material('Nakiri oxblood ferrule',(.23,.048,.036),.55)
maple=material('Nakiri pale maple butt cap',(.65,.49,.28),.60)
cutting=DATA['edge'];outline=cutting+[[1.43,.36],[1.37,.40],[.04,.40],[-.09,.29]]
prism('Nakiri squared vegetable blade',outline,.022,0,steel,.007)
for side in [-1,1]:
 prism('Nakiri long double-sided polished bevel',cutting+[[x,y+.090] for x,y in reversed(cutting)],.001,side*.023,hone,.002)
 prism('Nakiri retained dark forged shoulder',[[.025,-.04],[.44,.015],[.85,-.015],[1.405,.045],[1.405,.355],[1.35,.375],[.04,.375]],.001,side*.024,forged,.004)
 for j in range(7):
  x=.14+j*.17
  prism('Nakiri subtle forged vertical marks',[(x,.19),(x+.014,.17),(x+.022,.32),(x+.008,.34)],.0005,side*.026,steel,.0005)
def octagon(name,start,end,y,z,mat):
 vertices=[]
 for x,scale in [(start,.94),(start+.035,1),(end-.035,1),(end,.94)]:
  vertices += [(x,y*scale*math.cos(math.pi/8+j*math.pi/4),z*scale*math.sin(math.pi/8+j*math.pi/4)) for j in range(8)]
 faces=[tuple(range(7,-1,-1)),tuple(range(24,32))]
 for k in range(3):
  for j in range(8):faces.append((k*8+j,k*8+(j+1)%8,(k+1)*8+(j+1)%8,(k+1)*8+j))
 return mesh(name,vertices,faces,mat,False)
octagon('Nakiri substantial octagonal walnut grip',-1.14,-.23,.135,.097,walnut)
octagon('Nakiri oxblood octagonal ferrule',-.26,-.075,.139,.100,ferrule)
octagon('Nakiri pale maple butt cap',-1.18,-1.12,.135,.097,maple)
for side in [-1,1]:
 for j in range(3):
  y=-.048+j*.044
  prism('Nakiri quiet walnut grain',[(-1.08,y),(-.87,y+.008),(-.63,y-.009),(-.33,y+.005),(-.63,y-.003),(-.87,y+.013)],.0006,side*.090,grain,.0003)
export('assets/models/knives/nakiri.glb')
bpy.ops.import_scene.gltf(filepath=str(ROOT/'assets/models/knives/nakiri.glb'))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/nakiri.blend'))
