"""Original broad eight-lobed Beefsteak with six meaty seeded chambers."""
from pathlib import Path
import json
import math
import sys
import bpy
sys.path.insert(0, str(Path(__file__).resolve().parent))
from blender_meshes import ROOT, clear, material, mesh, sphere, clip, export

DATA = next(d for d in json.loads((ROOT/'data/tomatoes.json').read_text()) if d['id'] == 'beefsteak')
AXES = DATA['proxy_axes']
LOBE, LOBES, TAPER = (DATA[k] for k in ['proxy_lobe', 'proxy_lobe_count', 'proxy_taper'])
clear()
skin = material('Beefsteak broad scarlet skin', (.48, .035, .020), .39)
flesh = material('Beefsteak dense coral flesh', (.64, .145, .090), .33)
pith = material('Beefsteak creamy six-way pith', (.84, .50, .29), .46)
gel = material('Beefsteak deep crimson chambers', (.26, .030, .020), .25)
seed = material('Beefsteak plump ivory seeds', (.92, .78, .52), .39)
green = material('Beefsteak heavy olive crown', (.11, .17, .060), .66)
scar = material('Beefsteak corked stem scar', (.20, .10, .035), .75)


def shape(x, y, z):
    lobe = 1+LOBE*math.cos(LOBES*math.atan2(z, x))*(1-y*y)
    taper = 1-TAPER*y
    return (x*AXES[0]*lobe*taper, y*AXES[1], z*AXES[2]*lobe*taper)


def shell(half=False):
    vertices, faces = [], []
    rings, segments = 28, 64
    for i in range(rings+1):
        a = math.pi*(.5 if half else 1)*i/rings
        for j in range(segments):
            t = math.tau*j/segments
            point = (math.cos(a), math.sin(a)*math.cos(t), math.sin(a)*math.sin(t)) if half else (math.sin(a)*math.cos(t), math.cos(a), math.sin(a)*math.sin(t))
            vertices.append(shape(*point))
    for i in range(rings):
        for j in range(segments):
            a, b = i*segments+j, i*segments+(j+1) % segments
            face = (a, b, b+segments, a+segments)
            faces.append(tuple(reversed(face)) if half else face)
    mesh('Prepared Beefsteak half' if half else 'Broad eight-shouldered Beefsteak shell', vertices, faces, skin)


def crown():
    sphere('Recessed Beefsteak stem scar', (0, AXES[1]-.006, 0), (.18, .018, .16), scar, 24, 10)
    for j in range(8):
        t = math.tau*j/8
        length = .39+(.025 if j % 2 else 0)
        points = [(0, AXES[1]+.008, 0),
                  (.17*math.cos(t-.43), AXES[1]+.028, .17*math.sin(t-.43)),
                  (length*math.cos(t), AXES[1]-.055, length*math.sin(t)),
                  (.17*math.cos(t+.43), AXES[1]+.028, .17*math.sin(t+.43)),
                  (.18*math.cos(t), AXES[1]+.095, .18*math.sin(t))]
        ob = mesh('Heavy folded Beefsteak calyx', points, [(0, 1, 4), (1, 2, 4), (2, 3, 4), (3, 0, 4)], green)
        mod = ob.modifiers.new('Thick botanical crown', 'SOLIDIFY')
        mod.thickness = .019
    for j in range(11):
        t = j/10
        sphere('Crooked substantial Beefsteak stem', (-.12*t*t, AXES[1]+.02+.23*t, .045*math.sin(t*math.pi)), (.044, .042, .044), green)


def half():
    shell(True)
    rim = [(-.003, *shape(0, math.cos(math.tau*j/64), math.sin(math.tau*j/64))[1:]) for j in range(64)]
    mesh('Thick six-chamber Beefsteak flesh', [(-.003, 0, 0)]+rim, [(0, (j+1) % 64+1, j+1) for j in range(64)], flesh, False)
    sphere('Broad Beefsteak central pith', (-.016, .015, 0), (.014, .16, .20), pith)
    for j in range(6):
        t = math.tau*j/6
        cy, cz = .33*math.cos(t), .47*math.sin(t)
        ob = sphere('Six unequal Beefsteak gel pockets', (-.014, cy, cz), (.012, .13+(.012 if j % 2 else 0), .13), gel, 20, 10)
        ob.rotation_euler.x = t
        for k in range(4):
            a = t+(k-1.5)*.19
            ob = sphere('Modeled plump Beefsteak seed', (-.030, .33*math.cos(a), .47*math.sin(a)), (.012, .033, .020), seed)
            ob.rotation_euler.x = a
        t += math.pi/6
        points = [(-.017, ry*math.cos(t+a), rz*math.sin(t+a)) for ry, rz, a in [(.13, .17, -.16), (.45, .61, -.025), (.45, .61, .025), (.13, .17, .16)]]
        mesh('Broad six-way Beefsteak septum', points, [(0, 1, 2, 3)], pith, False)


shell()
crown()
export('assets/models/tomatoes/beefsteak.glb')
half()
export('assets/models/fragments/beefsteak_half.glb')
half()
clip((0, 1, 0), flesh, 'Prepared Beefsteak half')
export('assets/models/fragments/beefsteak_wedge.glb')
half()
clip((0, 1, 0), flesh, 'Prepared Beefsteak half')
clip((1, -1, 0), flesh, 'Prepared Beefsteak half')
ob = sphere('Fresh Beefsteak diagonal gel', (.20, .20, 0), (.010, .11, .24), gel, 20, 10)
ob.rotation_euler.z = -math.pi/4
for z in [-.14, 0, .14]:
    ob = sphere('Fresh Beefsteak diagonal seed', (.191, .209, z), (.012, .032, .020), seed)
    ob.rotation_euler.z = -math.pi/4
export('assets/models/fragments/beefsteak_chunk.glb')
for path in ['assets/models/tomatoes/beefsteak.glb']+['assets/models/fragments/beefsteak_'+kind+'.glb' for kind in ['half', 'wedge', 'chunk']]:
    bpy.ops.import_scene.gltf(filepath=str(ROOT/path))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/beefsteak.blend'))
