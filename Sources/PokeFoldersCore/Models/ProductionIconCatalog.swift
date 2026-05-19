import Foundation

public enum ProductionIconCatalog {
    public static let allPacks: [IconPack] = [
        pack(
            id: "starter",
            name: "Starter Pack",
            description: "Five approachable elemental folders for a first creature-team desktop.",
            category: .starter,
            accent: 0xff7a45,
            icons: [
                seed("starter-flame", "Flame Starter", .fire, 0xf05a3a, 0xffc15a, 0xff8d5c, [.flame, .ember], .flame, .ember, .glossy, .elevated, .center, 0.64, 0.45),
                seed("starter-aqua", "Aqua Starter", .water, 0x35aee2, 0xb4f1ff, 0x83dcff, [.droplet, .bubble], .droplet, .aura, .glass, .soft, .topRight, 0.46, 0.35),
                seed("starter-leaf", "Leaf Starter", .grass, 0x53b86f, 0xd6f47b, 0x9be370, [.leaf, .natureAura], .leaf, .soft, .matte, .soft, .topRight, 0.38, 0.34),
                seed("starter-thunder", "Thunder Buddy", .electric, 0xffd94f, 0x2f2b66, 0xffed92, [.thunder, .plasma], .thunder, .neon, .glossy, .elevated, .topRight, 0.7, 0.32),
                seed("starter-mystic", "Mystic Core", .mystic, 0x8a67e8, 0xffb7f3, 0xbfa8ff, [.mysticCore, .cosmic], .mysticCore, .aura, .aura, .soft, .watermark, 0.62, 0.38)
            ]
        ),
        pack(
            id: "legendary",
            name: "Legendary Pack",
            description: "Gold, crystal, cosmic, royal, and ancient designs with a premium aura system.",
            category: .legendary,
            accent: 0xd7a72f,
            icons: [
                seed("legendary-gold-aura", "Gold Aura", .legendary, 0xd8a326, 0xffe18b, 0xffcc58, [.goldAura, .mysticCore], .goldAura, .aura, .brushed, .dramatic, .center, 0.78, 0.48),
                seed("legendary-crystal", "Crystal Prism", .legendary, 0x8fd9ff, 0xffffff, 0xd8f5ff, [.crystal, .mysticCore], .crystal, .soft, .crystalline, .elevated, .topRight, 0.52, 0.36),
                seed("legendary-cosmic", "Cosmic Beast", .legendary, 0x303063, 0xffd36e, 0x5c55aa, [.cosmic, .void], .cosmic, .cosmic, .aura, .dramatic, .watermark, 0.82, 0.62),
                seed("legendary-royal-dragon", "Royal Dragon", .dragon, 0x7b244c, 0xffd76d, 0xaa3860, [.dragonCrest, .goldAura], .dragonCrest, .aura, .brushed, .dramatic, .center, 0.68, 0.58),
                seed("legendary-ancient-rune", "Ancient Rune", .legendary, 0x7b6542, 0xf4c66a, 0xb99152, [.rune, .goldAura], .rune, .soft, .matte, .long, .topRight, 0.36, 0.5)
            ]
        ),
        pack(
            id: "electric",
            name: "Electric Pack",
            description: "Neon, lightning, cyber, storm, and plasma folders for high-energy workspaces.",
            category: .electric,
            accent: 0xffdf39,
            icons: [
                seed("electric-neon-yellow", "Neon Yellow", .electric, 0xffde33, 0x1d244f, 0xfff08a, [.thunder, .plasma], .thunder, .neon, .glossy, .elevated, .topRight, 0.76, 0.32),
                seed("electric-lightning-bolt", "Lightning Bolt", .electric, 0xffb91f, 0xffffff, 0xffdc63, [.thunder, .storm], .thunder, .neon, .brushed, .dramatic, .center, 0.82, 0.45),
                seed("electric-cyber-spark", "Cyber Spark", .electric, 0x21d4d2, 0xfff35a, 0x64f3ff, [.cyberSpark, .plasma], .cyberSpark, .neon, .pixel, .soft, .topRight, 0.66, 0.34),
                seed("electric-storm", "Storm Charge", .electric, 0x4d5c91, 0xc4d8ff, 0x7d8cff, [.storm, .thunder], .storm, .aura, .glass, .dramatic, .watermark, 0.7, 0.58),
                seed("electric-plasma", "Plasma Ring", .electric, 0x7c55ff, 0x4ffff0, 0xa890ff, [.plasma, .cyberSpark], .plasma, .neon, .aura, .elevated, .center, 0.78, 0.4)
            ]
        ),
        pack(
            id: "fire",
            name: "Fire Pack",
            description: "Ember, lava, dragon flame, volcanic, and inferno icons with warm layered light.",
            category: .fire,
            accent: 0xff6533,
            icons: [
                seed("fire-ember", "Ember Folder", .fire, 0xe65338, 0xffc05b, 0xff8752, [.ember, .flame], .ember, .ember, .matte, .soft, .topRight, 0.55, 0.4),
                seed("fire-lava", "Lava Flow", .fire, 0x8f261d, 0xff8c24, 0xd9442e, [.lava, .inferno], .lava, .ember, .aura, .dramatic, .watermark, 0.72, 0.56),
                seed("fire-dragon-flame", "Dragon Flame", .dragon, 0xb8342b, 0xffd16a, 0xff7355, [.dragonCrest, .flame], .dragonCrest, .ember, .brushed, .dramatic, .center, 0.68, 0.5),
                seed("fire-volcanic", "Volcanic Core", .fire, 0x4a1d1d, 0xff6733, 0x8d3331, [.volcano, .lava], .volcano, .ember, .matte, .long, .center, 0.64, 0.66),
                seed("fire-inferno", "Inferno Crest", .fire, 0xff442f, 0xffe38e, 0xff7653, [.inferno, .flame], .inferno, .ember, .glossy, .dramatic, .topRight, 0.82, 0.48)
            ]
        ),
        pack(
            id: "water",
            name: "Water Pack",
            description: "Ocean, bubble, ice-blue, wave, and deep sea designs with clear glass finishes.",
            category: .water,
            accent: 0x38bdf8,
            icons: [
                seed("water-ocean", "Ocean Folder", .water, 0x247ebd, 0x9be7ff, 0x73cbff, [.ocean, .wave], .ocean, .aura, .glass, .soft, .watermark, 0.48, 0.34),
                seed("water-bubble", "Bubble Folder", .water, 0x5ac8fa, 0xffffff, 0xb9efff, [.bubble, .droplet], .bubble, .soft, .glossy, .soft, .topRight, 0.44, 0.3),
                seed("water-ice-blue", "Ice Blue", .water, 0xa7e8ff, 0x4a8bc9, 0xd7f8ff, [.ice, .crystal], .ice, .soft, .crystalline, .elevated, .topRight, 0.38, 0.32),
                seed("water-wave", "Wave Crest", .water, 0x2f9ed1, 0xd4fbff, 0x82dfff, [.wave, .ocean], .wave, .aura, .glass, .elevated, .center, 0.54, 0.36),
                seed("water-deep-sea", "Deep Sea", .water, 0x123a66, 0x5ee9ff, 0x265b8f, [.deepSea, .void], .deepSea, .aura, .matte, .dramatic, .watermark, 0.6, 0.62)
            ]
        ),
        pack(
            id: "grass",
            name: "Grass Pack",
            description: "Forest, vine, nature aura, leaf crest, and jungle folders with botanical detail.",
            category: .grass,
            accent: 0x60c878,
            icons: [
                seed("grass-forest", "Forest Folder", .grass, 0x3f8f58, 0xc9ec86, 0x78c76d, [.forest, .leaf], .forest, .soft, .matte, .soft, .watermark, 0.38, 0.36),
                seed("grass-vine", "Vine Folder", .grass, 0x4fa35d, 0xe1f783, 0x8edc72, [.vine, .leaf], .vine, .aura, .brushed, .elevated, .center, 0.5, 0.38),
                seed("grass-nature-aura", "Nature Aura", .grass, 0x71c96e, 0xfff0a2, 0xaee985, [.natureAura, .mysticCore], .natureAura, .aura, .aura, .soft, .watermark, 0.62, 0.34),
                seed("grass-leaf-crest", "Leaf Crest", .grass, 0x2f7d45, 0xd7f071, 0x6ebf62, [.leafCrest, .leaf], .leafCrest, .soft, .glossy, .elevated, .topRight, 0.42, 0.36),
                seed("grass-jungle", "Jungle Folder", .grass, 0x246b45, 0x93d96d, 0x4f9b57, [.jungle, .vine], .jungle, .aura, .matte, .dramatic, .center, 0.48, 0.52)
            ]
        ),
        pack(
            id: "dark",
            name: "Dark Pack",
            description: "Shadow, ghost aura, moon, void, and purple smoke folders for moody desktops.",
            category: .dark,
            accent: 0x7f67d9,
            icons: [
                seed("dark-shadow", "Shadow Folder", .dark, 0x23233a, 0x7d70d8, 0x383650, [.shadow, .void], .shadow, .shadow, .matte, .dramatic, .watermark, 0.58, 0.72),
                seed("dark-ghost-aura", "Ghost Aura", .ghost, 0x4b3f79, 0xb8a5ff, 0x68579e, [.ghostAura, .smoke], .ghostAura, .aura, .aura, .elevated, .center, 0.64, 0.55),
                seed("dark-moon", "Moon Folder", .dark, 0x2c2f55, 0xf0e6b8, 0x4b4f7a, [.moon, .mysticCore], .moon, .soft, .glass, .dramatic, .topRight, 0.48, 0.55),
                seed("dark-void", "Void Folder", .dark, 0x151525, 0x7ff0ff, 0x2a2940, [.void, .cosmic], .void, .shadow, .aura, .dramatic, .watermark, 0.74, 0.78),
                seed("dark-purple-smoke", "Purple Smoke", .dark, 0x5b3d82, 0xd4a8ff, 0x725196, [.smoke, .ghostAura], .smoke, .aura, .matte, .long, .center, 0.62, 0.58)
            ]
        ),
        pack(
            id: "pixel-retro",
            name: "Pixel Retro Pack",
            description: "8-bit, pixel creature, retro console, arcade badge, and classic game folders.",
            category: .pixelRetro,
            accent: 0x5f7cff,
            icons: [
                seed("pixelretro-8-bit", "8 Bit Folder", .pixel, 0x496ddb, 0xffd45b, 0x72d6ff, [.pixelBlock, .classicGame], .pixelBlock, .pixel, .pixel, .pixel, .center, 0.24, 0.55),
                seed("pixelretro-creature", "Pixel Creature", .pixel, 0x35a97b, 0xfff071, 0x78d7a8, [.pixelCreature, .classicGame], .pixelCreature, .pixel, .pixel, .pixel, .center, 0.24, 0.5),
                seed("pixelretro-console", "Retro Console", .pixel, 0x6654d9, 0xf3f1ff, 0x8d83ff, [.retroConsole, .pixelBlock], .retroConsole, .pixel, .pixel, .pixel, .topRight, 0.22, 0.5),
                seed("pixelretro-arcade-badge", "Arcade Badge", .pixel, 0xf05a78, 0x67f1ff, 0xff91a5, [.arcadeBadge, .thunder], .arcadeBadge, .pixel, .pixel, .pixel, .center, 0.22, 0.48),
                seed("pixelretro-classic-game", "Classic Game", .pixel, 0x2f334f, 0xffd35b, 0x565d87, [.classicGame, .pixelCreature], .classicGame, .pixel, .pixel, .pixel, .watermark, 0.24, 0.58)
            ]
        )
    ]

    public static var allDesigns: [FolderIconDesign] {
        allPacks.flatMap(\.icons)
    }

    public static func pack(id: String) -> IconPack? {
        allPacks.first { $0.id == id }
    }

    public static func design(id: String) -> FolderIconDesign? {
        allDesigns.first { $0.id == id }
    }

    private static func pack(
        id: String,
        name: String,
        description: String,
        category: ThemeCategory,
        accent: UInt32,
        icons seeds: [DesignSeed]
    ) -> IconPack {
        let icons = seeds.map { makeDesign($0, packId: id) }
        return IconPack(
            id: id,
            name: name,
            description: description,
            category: category,
            icons: icons,
            previewImage: "\(id)-preview",
            accentColor: RGBAColor(hex: accent),
            isPremium: true
        )
    }

    private static func seed(
        _ id: String,
        _ name: String,
        _ type: ElementType,
        _ base: UInt32,
        _ accent: UInt32,
        _ tab: UInt32,
        _ badges: [BadgeStyle],
        _ primaryBadge: BadgeStyle,
        _ glow: GlowStyle,
        _ texture: TextureStyle,
        _ shadow: ShadowStyle,
        _ position: BadgePosition,
        _ glowIntensity: Double,
        _ shadowIntensity: Double
    ) -> DesignSeed {
        DesignSeed(
            id: id,
            name: name,
            type: type,
            base: base,
            accent: accent,
            tab: tab,
            badges: badges,
            primaryBadge: primaryBadge,
            glow: glow,
            texture: texture,
            shadow: shadow,
            position: position,
            glowIntensity: glowIntensity,
            shadowIntensity: shadowIntensity
        )
    }

    private static func makeDesign(_ seed: DesignSeed, packId: String) -> FolderIconDesign {
        let exportBaseName = seed.id.replacingOccurrences(of: "-", with: "_")
        let baseColor = RGBAColor(hex: seed.base)
        let accentColor = RGBAColor(hex: seed.accent)
        let tabColor = RGBAColor(hex: seed.tab)
        let gradientColors = [
            tabColor.adjusted(brightness: 0.08),
            baseColor,
            baseColor.mixed(with: accentColor, amount: 0.34).adjusted(brightness: -0.08),
            accentColor.withAlpha(0.72)
        ]
        let prompt = prompt(iconName: seed.name, type: seed.type.title, badges: seed.badges.map(\.title).joined(separator: ", "))
        return FolderIconDesign(
            id: seed.id,
            name: seed.name,
            packId: packId,
            type: seed.type,
            baseColor: baseColor,
            accentColor: accentColor,
            tabColor: tabColor,
            gradientColors: gradientColors,
            badgeStyle: seed.primaryBadge,
            glowStyle: seed.glow,
            textureStyle: seed.texture,
            shadowStyle: seed.shadow,
            badgePosition: seed.position,
            cornerRadius: seed.texture == .pixel ? 24 : 54,
            glowIntensity: seed.glowIntensity,
            shadowIntensity: seed.shadowIntensity,
            exportFileNames: [
                "base": exportBaseName,
                "1024": "\(exportBaseName)_1024.png",
                "512": "\(exportBaseName)_512.png",
                "256": "\(exportBaseName)_256.png",
                "128": "\(exportBaseName)_128.png"
            ],
            generationPrompt: prompt,
            negativePrompt: standardNegativePrompt
        )
    }

    public static func prompt(iconName: String, type: String, badges: String) -> String {
        "Single 1024x1024 transparent-background macOS folder icon named \(iconName), original \(type.lowercased()) collectible-creature inspired design, Apple-like rounded folder silhouette with realistic tab, layered gradients, soft ambient shadow, glossy highlight stroke, subtle texture, premium 3D/vector hybrid finish, centered composition, high-quality elemental badge motifs: \(badges), no text, no logo."
    }

    public static let standardNegativePrompt = "No official Pokemon characters, no official Pokemon logos, no Pokeball exact logo, no Nintendo/Game Freak/The Pokemon Company branding, no copyrighted character artwork, no text, no watermark, no busy background, no cropped icon, no low-resolution artifacts."
}

private struct DesignSeed {
    var id: String
    var name: String
    var type: ElementType
    var base: UInt32
    var accent: UInt32
    var tab: UInt32
    var badges: [BadgeStyle]
    var primaryBadge: BadgeStyle
    var glow: GlowStyle
    var texture: TextureStyle
    var shadow: ShadowStyle
    var position: BadgePosition
    var glowIntensity: Double
    var shadowIntensity: Double
}
