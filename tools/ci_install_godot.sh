#!/usr/bin/env bash
# Official standard editor/templates, verified against upstream SHA-512.
set -euo pipefail
version=4.6.3
install_dir="${RUNNER_TEMP:-/tmp}/tomatocut-godot-${version}"
mkdir -p "$install_dir"
cd "$install_dir"
base="https://github.com/godotengine/godot-builds/releases/download/${version}-stable"
editor="Godot_v${version}-stable_linux.x86_64.zip"
templates="Godot_v${version}-stable_export_templates.tpz"
for asset in SHA512-SUMS.txt "$editor" "$templates"; do
    curl --fail --location --retry 3 --output "$asset" "$base/$asset"
done
# Verify only the downloaded archives, without ignoring a mismatch.
awk -v editor="$editor" -v templates="$templates" '$2 == editor || $2 == templates { print }' SHA512-SUMS.txt > selected.sha512
test "$(wc -l < selected.sha512)" -eq 2
sha512sum --check selected.sha512
unzip -q -o "$editor" -d editor
chmod +x "editor/Godot_v${version}-stable_linux.x86_64"
mkdir -p bin
ln -sf "$install_dir/editor/Godot_v${version}-stable_linux.x86_64" bin/godot
unzip -q -o "$templates" templates/windows_release_x86_64.exe templates/linux_release.x86_64 -d unpacked
export_template_dir="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/${version}.stable"
mkdir -p "$export_template_dir"
cp unpacked/templates/* "$export_template_dir/"
# The workflow receives PATH only after this successful, verified installation.
if [[ -n "${GITHUB_PATH:-}" ]]; then
    printf '%s\n' "$install_dir/bin" >> "$GITHUB_PATH"
fi
"$install_dir/bin/godot" --headless --version
