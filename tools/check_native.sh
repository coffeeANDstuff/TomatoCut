#!/usr/bin/env bash
# Requires a working Linux desktop display. Test saves use user://tests/ only.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p artifacts/native
failed=0
for flow in render_smoke harvest_render roma_render discovery_render critical_render \
  equipment_render modification_render steak_render prestige_render golden_render \
  stampede_render button_render giant_render rainbow_render jackpot_render \
  permanent_time_render permanent_production_render permanent_cutting_render \
  permanent_harvest_render weak_point_render heirloom_render ultimate_render \
  stampede_combo_render golden_multiplier_render golden_jackpot_render production_polish_render campari_render santoku_render chef_render cleaver_render bread_render; do
  if ./tools/ci_godot.sh --path . --rendering-method gl_compatibility --audio-driver Dummy \
      --script "tests/$flow.gd" > "artifacts/native/$flow.log" 2>&1; then
    printf 'PASS: %s\n' "$flow"
  else
    printf 'FAIL: %s (artifacts/native/%s.log)\n' "$flow" "$flow" >&2
    tail -30 "artifacts/native/$flow.log" >&2
    failed=1
  fi
done
exit "$failed"
