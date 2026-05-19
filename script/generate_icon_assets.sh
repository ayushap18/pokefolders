#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRATCH_DIR="${TMPDIR:-/tmp}/pokefolders-swiftpm"
cd "$ROOT_DIR"

swift build --scratch-path "$SCRATCH_DIR" --product PokeFoldersAssetGenerator
"$(swift build --scratch-path "$SCRATCH_DIR" --show-bin-path)/PokeFoldersAssetGenerator"
