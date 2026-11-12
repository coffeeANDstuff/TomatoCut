#!/usr/bin/env bash
# Explicit wrapper for this managed workspace; ordinary desktop users do not need it.
set -euo pipefail
runtime_dir=/workspace/.tomatocut-runtime
export XDG_DATA_HOME="$runtime_dir/data"
export XDG_CACHE_HOME="$runtime_dir/cache"
export XDG_CONFIG_HOME="$runtime_dir/config"
mkdir -p "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME"
exec "$@"
