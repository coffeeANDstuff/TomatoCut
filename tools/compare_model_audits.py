"""Compare audit_models.gd outputs without relying on rounding-boundary hashes."""
import argparse
import itertools
import json
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('original', type=Path)
parser.add_argument('batched', type=Path)
args = parser.parse_args()
before, after = (json.loads(p.read_text()) for p in [args.original, args.batched])
assert before.keys() == after.keys(), 'Model coverage changed'
offsets = list(itertools.product([-1, 0, 1], repeat=3))
proof = []
for name in before:
    a, b = before[name], after[name]
    assert a['triangles'] == b['triangles'], name + ': geometry reduced'
    sets = [{tuple(map(int, point.split(','))) for point in item['point_set']} for item in [a, b]]
    for source, target in [sets, sets[::-1]]:
        for point in source - target:
            assert any(tuple(x + d for x, d in zip(point, offset)) in target for offset in offsets), name + ': changed world vertex'
    proof.append({'model': name, 'meshes_before': a['meshes'], 'meshes_after': b['meshes'], 'triangles': a['triangles']})
print(json.dumps({'models': proof, 'triangles_unchanged': True,
                  'world_position_quantization': .0001, 'maximum_neighbor_cell_offset': 1}, indent=2))
