#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Import registers global classes and resolves GLBs/fonts on a fresh checkout.
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/run_tests.gd
