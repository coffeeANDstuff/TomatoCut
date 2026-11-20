"""Original scalloped Bread Knife, raised bakelite scales and ivory grip pins."""
from pathlib import Path
import json,sys,math,bpy
sys.path.insert(0,str(Path(__file__).resolve().parent))
from blender_meshes import ROOT,clear,material,prism,export
DATA=next(d for d in json.loads((ROOT/'data/knives.json').read_text()) if d['id']=='bread');clear()
steel=material('Bread satin nickel steel',(.42,.49,.49),.53,.57)
edge=material('Bread polished scalloped facet',(.70,.75,.72),.46,.48)
tang=material('Bread full dark steel tang',(.13,.17,.16),.53,.61)
grip=material('Bread charcoal-green bakelite',(.026,.063,.054),.52)
ivory=material('Bread cream through pins',(.80,.73,.55),.52)
brass=material('Bread quiet brass ferrule',(.39,.28,.12),.48,.65)
cutting=DATA['edge']
outline=cutting+[[1.70,.13],[1.65,.24],[-.12,.24]]
prism('Twelve actual Bread scallops',outline,.024,0,steel,.003)
# Both bevel outlines track the same sampled cutting polyline used in gameplay.
facet=cutting+[[x,y+.029] for x,y in reversed(cutting)]
for side in [-1,1]:prism('Continuous double-sided scalloped honing',facet,.001,side*.025,edge,.001)
handle=[(-1.10,-.11),(-.94,-.16),(-.62,-.15),(-.31,-.08),(-.20,-.12),(-.13,-.02),(-.19,.14),(-.46,.20),(-.80,.22),(-1.07,.16)]
prism('Bread sculpted full tang',handle,.051,0,tang,.023)
for side in [-1,1]:
 prism('Raised charcoal-green Bread scales',[(x,y*.94) for x,y in handle],.030,side*.057,grip,.027)
 for x in [-.88,-.77,-.66]:
  prism('Shallow tactile Bread grip flute',[(x,-.095),(x+.014,-.095),(x+.014,.17),(x,.17)],.001,side*.088,tang,.001)
prism('Brass Bread ferrule',[(-.23,-.13),(-.12,-.13),(-.12,.25),(-.23,.22)],.065,0,brass,.010)
for x,y in [(-.99,.016),(-.57,.034),(-.31,.026)]:
 bpy.ops.mesh.primitive_cylinder_add(vertices=24,radius=.024,depth=.179,location=(x,y,0));ob=bpy.context.object;ob.name='Three Bread ivory through pins';ob.data.materials.append(ivory)
 mod=ob.modifiers.new('Soft ivory pin lips','BEVEL');mod.width=.003;mod.segments=2
export('assets/models/knives/bread.glb')
bpy.ops.import_scene.gltf(filepath=str(ROOT/'assets/models/knives/bread.glb'))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/bread_knife.blend'))
