"""Original compact Paring Knife. Blender 4.3+, matching authored cutting edge."""
from pathlib import Path
import bpy, math
from mathutils import Matrix
ROOT=Path(__file__).resolve().parents[1]
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)

def material(name,color,roughness,metal=0):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
 p=m.node_tree.nodes['Principled BSDF'];p.inputs['Base Color'].default_value=m.diffuse_color;p.inputs['Roughness'].default_value=roughness;p.inputs['Metallic'].default_value=metal
 return m

def prism(name,outline,depth,z,mat,bevel):
 n=len(outline);v=[(x,y,z+side*depth) for side in [-1,1] for x,y in outline]
 f=[tuple(range(n-1,-1,-1)),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
 me=bpy.data.meshes.new(name);me.from_pydata(v,[],f);me.update();ob=bpy.data.objects.new(name,me);bpy.context.collection.objects.link(ob);ob.data.materials.append(mat)
 mod=ob.modifiers.new('Hand finished bevel','BEVEL');mod.width=bevel;mod.segments=3;ob.modifiers.new('Weighted normals','WEIGHTED_NORMAL');return ob

steel=material('Satin paring steel',(.47,.53,.52),.29,.78)
edge=material('Honed silver facet',(.65,.68,.62),.21,.87)
grip=material('Deep botanical green handle',(.035,.10,.073),.43)
brass=material('Quiet brass ferrule',(.43,.28,.10),.35,.7)
outline=[(-.08,-.055),(.47,-.055),(.72,-.005),(.83,.055),(.58,.14),(.24,.18),(-.08,.14)]
prism('Fine pointed paring blade',outline,.024,0,steel,.007)
prism('Visible honed lower facet',[(-.06,-.054),(.47,-.054),(.72,-.004),(.82,.054),(.69,.027),(.46,-.020),(-.06,-.020)],.002,.025,edge,.001)
handle=[(-.94,-.055),(-.83,-.10),(-.55,-.085),(-.28,-.10),(-.10,-.07),(-.10,.12),(-.28,.14),(-.55,.10),(-.82,.12),(-.95,.075)]
prism('Narrow sculpted green grip',handle,.065,0,grip,.036)
prism('Brass shoulder ferrule',[(-.19,-.10),(-.08,-.075),(-.08,.15),(-.19,.16)],.067,0,brass,.012)
for x in [-.78,-.39]:
 bpy.ops.mesh.primitive_cylinder_add(vertices=20,radius=.021,depth=.14,location=(x,.017,0));ob=bpy.context.object;ob.name='Flush brass grip pin';ob.data.materials.append(brass)
for x in [-.66,-.60,-.54]:
 prism('Fine engraved handle fluting',[(x,-.04),(x+.007,-.04),(x+.007,.075),(x,.075)],.001,.065,brass,.001)
bpy.context.view_layer.update()
for ob in bpy.context.scene.objects: ob.matrix_world=Matrix.Rotation(math.pi/2,4,'X')@ob.matrix_world
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets/models/knives/paring.glb'),export_format='GLB',use_selection=True,export_apply=True)
bpy.ops.object.delete(use_global=False);bpy.ops.import_scene.gltf(filepath=str(ROOT/'assets/models/knives/paring.glb'))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/paring_knife.blend'))
