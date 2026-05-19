# PokeFolders Icon Design System

PokeFolders icons are original macOS folder designs inspired by elemental creature-collection games. They must never copy official characters, logos, marks, or visual identities from Pokemon, Nintendo, Game Freak, Creatures Inc., or The Pokemon Company.

## Folder Shape Rules

- Use a recognizable macOS-style folder silhouette at every size.
- Keep the folder body centered in a 512x512 or 1024x1024 transparent canvas.
- Body bounds should preserve breathing room on all sides for Finder shadows.
- Corners should be smooth and rounded except Pixel Retro designs, which may use tighter stepped radii.
- The folder tab must read clearly as a separate raised layer.
- Avoid exact replicas of any trademarked ball, badge, or creature silhouette.

## Color System

- Every icon uses a three-part palette: base color, tab color, and accent color.
- Production designs should include at least three gradient stops.
- Each pack has a dominant identity color:
  - Starter: approachable mixed elemental colors.
  - Legendary: gold, crystal, cosmic, royal, and ancient tones.
  - Electric: yellow, cyan, violet, and storm blue.
  - Fire: ember, lava, volcanic red, and warm gold.
  - Water: ocean blue, aqua, ice, and deep sea navy.
  - Grass: forest green, vine green, botanical yellow-green.
  - Dark: shadow navy, purple aura, smoke, moonlight.
  - Pixel Retro: saturated arcade colors with lower radius geometry.
- Avoid single-hue palettes; every icon needs contrast from tab, accent, shadow, and highlight layers.

## Glow Rules

- Glow is a supporting aura, not the primary shape.
- Fire and electric icons may use stronger glow.
- Dark and cosmic icons may use larger, softer aura fields.
- Pixel icons use blocky glow sparingly.
- Glow must remain inside the transparent canvas and should not clip at 1024x1024.

## Shadow Rules

- Use a soft grounded shadow beneath the folder.
- Legendary, dark, volcanic, and royal designs may use more dramatic shadows.
- Pixel designs use shorter, crisper shadows.
- Shadows must not flatten into black blobs at 128x128.

## Badge Positioning Rules

- Main badge positions: center, top-right, bottom-right, watermark.
- Top-right badges should sit comfortably inside the folder body, not on the canvas edge.
- Watermark badges must be low opacity and should not obscure the folder shape.
- Badges should be original symbolic motifs: flame, droplet, leaf, bolt, moon, rune, crystal, wave, pixel creature, arcade mark.
- Do not use official character faces, exact Pokeball geometry, official gym icons, or trademarked symbols.

## Texture Rules

- Glossy: soft top highlight and subtle rim stroke.
- Matte: low-contrast linear grain.
- Glass: light internal edge and translucent reflection.
- Pixel: grid texture with crisp nearest-neighbor rendering.
- Brushed: fine parallel highlight strokes.
- Aura: small glow particles and low-opacity energy marks.
- Crystalline: angular low-opacity facets.

## Export Rules

- Production PNG assets must be transparent-background PNGs.
- Required sizes: 1024, 512, 256, and 128.
- Full pack export structure:
  - `PNG/1024`
  - `PNG/512`
  - `PNG/256`
  - `PNG/128`
  - `ICNS-Ready`
  - `README.txt`
- Ultra export mode uses best antialiasing and high interpolation.
- Pixel Retro exports preserve sharp pixel edges.

## Naming Rules

- Use descriptive generic names:
  - Flame Starter
  - Aqua Starter
  - Thunder Buddy
  - Mystic Core
  - Dragon Flame
  - Shadow Spirit
  - Cosmic Beast
- File names use lowercase pack prefixes and snake case:
  - `starter_flame_1024.png`
  - `legendary_cosmic_512.png`
  - `pixelretro_classic_game_128.png`
- Avoid official franchise, character, move, region, species, and item names.

## Pack Identity Rules

- Each pack contains exactly five designs.
- Each icon must have a unique color palette, badge style, texture, and glow/shadow personality.
- Pack cards in the app should preview pack identity through accent color and icon count.
- The app must allow searching and filtering by broad type: Fire, Water, Grass, Electric, Dark, Mystic, Legendary, Pixel.

## Copyright Safety Rules

- Never include official Pokemon, Nintendo, Game Freak, Creatures Inc., or The Pokemon Company assets.
- Never use official logos, character artwork, exact Pokeball marks, official badges, or names.
- Keep prompt language generic: elemental, creature-inspired, monster-catching, collectible-creature, original.
- Include a safety note in the app and exported pack README files.
- Generated assets should be reviewed before release for accidental similarity to protected characters or logos.
