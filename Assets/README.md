# PokeFolders Asset Pipeline

`Assets/IconPacks` contains CoreGraphics-rendered placeholder production PNGs for every bundled design. They are generated from the same Swift data model used by the app, so names, packs, colors, and prompt docs stay consistent.

## Regenerate Local PNGs

```bash
./script/generate_icon_assets.sh
```

This writes:

- `Assets/IconPacks/<PackName>/*_1024.png`
- `Assets/IconPacks/<PackName>/*_512.png`
- `Assets/IconPacks/<PackName>/*_256.png`
- `Assets/IconPacks/<PackName>/*_128.png`
- `Assets/GenerationPrompts/*-pack-prompts.md`

## Replacing with Image 2.0 Assets

1. Open the matching prompt file in `Assets/GenerationPrompts`.
2. Generate one transparent 1024x1024 PNG per icon.
3. Replace the matching `*_1024.png` file in `Assets/IconPacks/<PackName>`.
4. Downscale to 512, 256, and 128 using a high-quality image tool, or rerun the Swift renderer if you want deterministic vector placeholders.
5. Keep the same file names so app docs and export references stay stable.

All generated images must be original creature-inspired folder designs. Do not use official Pokemon characters, logos, exact Pokeball marks, character artwork, or trademarked names.
