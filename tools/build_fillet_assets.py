"""Original thin upswept Fillet Knife, sculpted honey-maple grip and dark guard."""
from pathlib import Path
import json,sys,bpy
sys.path.insert(0,str(Path(__file__).resolve().parent))
from blender_meshes import ROOT,clear,material,prism,export
DATA=next(d for d in json.loads((ROOT/'data/knives.json').read_text()) if d['id']=='fillet');clear()
steel=material('Fillet flexible satin steel',(.44,.51,.52),.49,.55)
edge=material('Fillet narrow honed facet',(.72,.77,.74),.44,.48)
maple=material('Fillet honey maple scales',(.45,.26,.10),.57)
grain=material('Fillet fine maple growth lines',(.26,.13,.048),.65)
dark=material('Fillet charcoal guard and heel',(.040,.055,.047),.64,.20)
pins=material('Fillet dark polished pins and tang',(.17,.22,.21),.47,.60)
copper=material('Fillet quiet copper collar',(.40,.22,.10),.48,.67)
cutting=DATA['edge'];outline=cutting+[[1.55,.255],[1.30,.15],[.83,.105],[-.10,.11]]
prism('Long narrow upswept Fillet blade',outline,.014,0,steel,.004)
facet=cutting+[[x,y+.025] for x,y in reversed(cutting)]
for side in [-1,1]:prism('Double-sided thin Fillet hone',facet,.001,side*.015,edge,.001)
handle=[(-1.08,-.065),(-.94,-.12),(-.67,-.11),(-.42,-.055),(-.24,-.10),(-.15,-.05),(-.14,.08),(-.29,.13),(-.58,.18),(-.89,.17),(-1.10,.10)]
prism('Slim Fillet full tang',handle,.049,0,pins,.022)
for side in [-1,1]:
 prism('Sculpted honey-maple Fillet scale',[(x,y*.94) for x,y in handle],.028,side*.053,maple,.024)
 for j in range(3):
  y=-.035+j*.044
  prism('Quiet modeled Fillet maple grain',[(-.98,y),(-.74,y+.017),(-.47,y-.003),(-.28,y+.012),(-.47,y+.003),(-.74,y+.024)],.0007,side*.082,grain,.0003)
prism('Dark Fillet finger guard',[(-.21,-.18),(-.10,-.16),(-.09,.20),(-.21,.22)],.068,0,dark,.013)
prism('Small Fillet copper collar',[(-.13,-.12),(-.075,-.10),(-.075,.185),(-.13,.19)],.047,0,copper,.007)
prism('Dark sculpted Fillet heel',[(-1.12,-.07),(-1.02,-.105),(-1.02,.15),(-1.12,.10)],.063,0,dark,.022)
for x,y in [(-.89,.025),(-.44,.018)]:
 bpy.ops.mesh.primitive_cylinder_add(vertices=24,radius=.024,depth=.166,location=(x,y,0));ob=bpy.context.object;ob.name='Two Fillet dark steel through pins';ob.data.materials.append(pins)
 mod=ob.modifiers.new('Rounded Fillet pin lip','BEVEL');mod.width=.003;mod.segments=2
export('assets/models/knives/fillet.glb')
bpy.ops.import_scene.gltf(filepath=str(ROOT/'assets/models/knives/fillet.glb'))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/fillet_knife.blend'))
