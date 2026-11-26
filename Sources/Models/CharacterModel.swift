import Foundation

/// Patient character representation for iOS.
public struct CharacterModel: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let gender: String
    public let skinToneHex: String
    public let hairColorHex: String
    public let shirtColorHex: String
    public let description: String
    public let dentalProblems: [ToothState]
    public var initialTeeth: [ToothModel]

    public init(
        id: String,
        name: String,
        gender: String,
        skinToneHex: String,
        hairColorHex: String,
        shirtColorHex: String,
        description: String,
        dentalProblems: [ToothState],
        initialTeeth: [ToothModel]
    ) {
        self.id = id
        self.name = name
        self.gender = gender
        self.skinToneHex = skinToneHex
        self.hairColorHex = hairColorHex
        self.shirtColorHex = shirtColorHex
        self.description = description
        self.dentalProblems = dentalProblems
        self.initialTeeth = initialTeeth
    }

    public static func createDefaultCharacters() -> [CharacterModel] {
        return [
            createLeo(),
            createMaya(),
            createKenji(),
            createAmara(),
            createMia(),
            createBen(),
            createLucas(),
            createHana(),
            createToby(),
            createZoe(),
            createAarav(),
            createElena(),
            createKai(),
            createFatima(),
            createSam(),
            createOliver(),
            createZara(),
            createMateo(),
            createLinh(),
            createArthur()
        ]
    }

    private static func createBaseTeeth() -> [ToothModel] {
        return [
            // Upper Arch (T01 - T06)
            ToothModel(id: "T01", arch: .upper, indexInArch: 0, type: .molar, normalizedX: 0.20, normalizedY: 0.44, state: .clean),
            ToothModel(id: "T02", arch: .upper, indexInArch: 1, type: .premolar, normalizedX: 0.31, normalizedY: 0.44, state: .clean),
            ToothModel(id: "T03", arch: .upper, indexInArch: 2, type: .incisor, normalizedX: 0.43, normalizedY: 0.44, state: .clean),
            ToothModel(id: "T04", arch: .upper, indexInArch: 3, type: .incisor, normalizedX: 0.57, normalizedY: 0.44, state: .clean),
            ToothModel(id: "T05", arch: .upper, indexInArch: 4, type: .premolar, normalizedX: 0.69, normalizedY: 0.44, state: .clean),
            ToothModel(id: "T06", arch: .upper, indexInArch: 5, type: .molar, normalizedX: 0.80, normalizedY: 0.44, state: .clean),
            // Lower Arch (T07 - T12)
            ToothModel(id: "T07", arch: .lower, indexInArch: 0, type: .molar, normalizedX: 0.20, normalizedY: 0.68, state: .clean),
            ToothModel(id: "T08", arch: .lower, indexInArch: 1, type: .premolar, normalizedX: 0.31, normalizedY: 0.68, state: .clean),
            ToothModel(id: "T09", arch: .lower, indexInArch: 2, type: .incisor, normalizedX: 0.43, normalizedY: 0.68, state: .clean),
            ToothModel(id: "T10", arch: .lower, indexInArch: 3, type: .incisor, normalizedX: 0.57, normalizedY: 0.68, state: .clean),
            ToothModel(id: "T11", arch: .lower, indexInArch: 4, type: .premolar, normalizedX: 0.69, normalizedY: 0.68, state: .clean),
            ToothModel(id: "T12", arch: .lower, indexInArch: 5, type: .molar, normalizedX: 0.80, normalizedY: 0.68, state: .clean)
        ]
    }

    private static func applyStates(_ states: [String: ToothState]) -> [ToothModel] {
        return createBaseTeeth().map { tooth in
            let state = states[tooth.id] ?? .clean
            return tooth.copyWithState(state)
        }
    }

    public static func createLeo() -> CharacterModel {
        CharacterModel(
            id: "char_01_leo",
            name: "Leo",
            gender: "male",
            skinToneHex: "#8D5524",
            hairColorHex: "#1A1A1A",
            shirtColorHex: "#F4B400",
            description: "An energetic boy who forgets to brush. His teeth are covered in candy stains and thick tartar.",
            dentalProblems: [.dirtStained, .calculus],
            initialTeeth: applyStates([
                "T01": .dirtStained, "T03": .calculus, "T06": .calculus,
                "T07": .dirtStained, "T09": .calculus, "T10": .dirtStained, "T11": .dirtStained
            ])
        )
    }

    public static func createMaya() -> CharacterModel {
        CharacterModel(
            id: "char_02_maya",
            name: "Maya",
            gender: "female",
            skinToneHex: "#FFDBAC",
            hairColorHex: "#FAD02C",
            shirtColorHex: "#0F9D58",
            description: "Loves chewy gummy candies at night. She has two cavities attacked by naughty sugar monsters.",
            dentalProblems: [.bacteria, .dirtStained],
            initialTeeth: applyStates([
                "T01": .dirtStained, "T02": .bacteria, "T08": .bacteria, "T11": .dirtStained
            ])
        )
    }

    public static func createKenji() -> CharacterModel {
        CharacterModel(
            id: "char_03_kenji",
            name: "Kenji",
            gender: "male",
            skinToneHex: "#F1C27D",
            hairColorHex: "#2C3437",
            shirtColorHex: "#E91E63",
            description: "Likes chewing on ice cubes. His enamel is stained with stubborn plaque along the gumline.",
            dentalProblems: [.dirtStained, .calculus],
            initialTeeth: applyStates([
                "T02": .dirtStained, "T03": .calculus, "T05": .dirtStained,
                "T07": .calculus, "T08": .dirtStained, "T10": .calculus, "T12": .dirtStained
            ])
        )
    }

    public static func createAmara() -> CharacterModel {
        CharacterModel(
            id: "char_04_amara",
            name: "Amara",
            gender: "female",
            skinToneHex: "#5C3836",
            hairColorHex: "#111111",
            shirtColorHex: "#9C27B0",
            description: "A fun-loving girl with crowded teeth that need a gentle clean and plaque removal.",
            dentalProblems: [.dirtStained, .calculus, .bacteria],
            initialTeeth: applyStates([
                "T01": .dirtStained, "T03": .bacteria, "T04": .calculus,
                "T06": .dirtStained, "T08": .calculus, "T09": .dirtStained,
                "T11": .calculus, "T12": .dirtStained
            ])
        )
    }

    public static func createMia() -> CharacterModel {
        CharacterModel(
            id: "char_05_mia",
            name: "Mia",
            gender: "female",
            skinToneHex: "#FFDFC4",
            hairColorHex: "#FF4081",
            shirtColorHex: "#2196F3",
            description: "Has sore tooth cavities and swollen gums caused by hungry germs. She needs gentle care!",
            dentalProblems: [.bacteria, .dirtStained],
            initialTeeth: applyStates([
                "T02": .dirtStained, "T04": .bacteria, "T06": .dirtStained,
                "T07": .bacteria, "T09": .dirtStained, "T10": .bacteria
            ])
        )
    }

    public static func createBen() -> CharacterModel {
        CharacterModel(
            id: "char_06_ben",
            name: "Uncle Ben",
            gender: "male",
            skinToneHex: "#C68642",
            hairColorHex: "#E0E0E0",
            shirtColorHex: "#212121",
            description: "An absent-minded professor with two loose decayed teeth that need gentle removal and implants.",
            dentalProblems: [.necroticCracked, .calculus, .dirtStained],
            initialTeeth: applyStates([
                "T01": .dirtStained, "T03": .calculus, "T04": .necroticCracked,
                "T05": .necroticCracked, "T06": .calculus, "T07": .dirtStained,
                "T09": .calculus, "T10": .dirtStained, "T11": .dirtStained, "T12": .calculus
            ])
        )
    }

    public static func createLucas() -> CharacterModel {
        CharacterModel(
            id: "char_07_lucas",
            name: "Lucas",
            gender: "male",
            skinToneHex: "#FED0B8",
            hairColorHex: "#D84315",
            shirtColorHex: "#42A5F5",
            description: "A 5-year-old boy who loves strawberry jam. His front teeth are covered in sweet orange stains.",
            dentalProblems: [.dirtStained],
            initialTeeth: applyStates([
                "T01": .dirtStained, "T02": .dirtStained, "T06": .dirtStained,
                "T07": .dirtStained, "T11": .dirtStained
            ])
        )
    }

    public static func createHana() -> CharacterModel {
        CharacterModel(
            id: "char_08_hana",
            name: "Hana",
            gender: "female",
            skinToneHex: "#FDEBD0",
            hairColorHex: "#3E2723",
            shirtColorHex: "#80CBC4",
            description: "Loves warm honey tea. She has yellow stains on her enamel and mild tartar near the gums.",
            dentalProblems: [.dirtStained, .calculus],
            initialTeeth: applyStates([
                "T02": .dirtStained, "T03": .calculus, "T06": .dirtStained,
                "T08": .dirtStained, "T09": .calculus, "T12": .dirtStained
            ])
        )
    }

    public static func createToby() -> CharacterModel {
        CharacterModel(
            id: "char_09_toby",
            name: "Toby",
            gender: "male",
            skinToneHex: "#E0A96D",
            hairColorHex: "#795548",
            shirtColorHex: "#FF9800",
            description: "Loves fruity gummies. Sticky candy residue has formed thick food stains between his teeth.",
            dentalProblems: [.dirtStained],
            initialTeeth: applyStates([
                "T01": .dirtStained, "T02": .dirtStained, "T04": .dirtStained,
                "T07": .dirtStained, "T08": .dirtStained, "T10": .dirtStained
            ])
        )
    }

    public static func createZoe() -> CharacterModel {
        CharacterModel(
            id: "char_10_zoe",
            name: "Zoe",
            gender: "female",
            skinToneHex: "#FFF0E1",
            hairColorHex: "#8D4925",
            shirtColorHex: "#BA68C8",
            description: "Enjoys blueberry smoothies. Her enamel has dark stains and stubborn plaque on the lower teeth.",
            dentalProblems: [.dirtStained, .calculus],
            initialTeeth: applyStates([
                "T01": .dirtStained, "T03": .calculus, "T05": .dirtStained,
                "T07": .calculus, "T08": .dirtStained, "T10": .calculus, "T11": .dirtStained
            ])
        )
    }

    public static func createAarav() -> CharacterModel {
        CharacterModel(
            id: "char_11_aarav",
            name: "Aarav",
            gender: "male",
            skinToneHex: "#9E6B47",
            hairColorHex: "#1C1917",
            shirtColorHex: "#1565C0",
            description: "Snuck dark chocolate before bed. Two molars have deep cavities where red germs are hiding.",
            dentalProblems: [.bacteria, .calculus, .dirtStained],
            initialTeeth: applyStates([
                "T01": .dirtStained, "T02": .bacteria, "T03": .calculus,
                "T07": .dirtStained, "T09": .bacteria, "T10": .calculus, "T12": .dirtStained
            ])
        )
    }

    public static func createElena() -> CharacterModel {
        CharacterModel(
            id: "char_12_elena",
            name: "Elena",
            gender: "female",
            skinToneHex: "#D7A374",
            hairColorHex: "#2E1C0C",
            shirtColorHex: "#FF5252",
            description: "An active girl who forgets to floss. She has heavy tartar along her tooth collars and one cavity.",
            dentalProblems: [.calculus, .bacteria, .dirtStained],
            initialTeeth: applyStates([
                "T01": .calculus, "T03": .dirtStained, "T04": .bacteria,
                "T06": .calculus, "T08": .calculus, "T09": .dirtStained,
                "T11": .calculus, "T12": .dirtStained
            ])
        )
    }

    public static func createKai() -> CharacterModel {
        CharacterModel(
            id: "char_13_kai",
            name: "Kai",
            gender: "male",
            skinToneHex: "#E5B887",
            hairColorHex: "#004D40",
            shirtColorHex: "#CDDC39",
            description: "Playfully bit on hard candy, chipping his enamel and letting bacteria penetrate the dentin.",
            dentalProblems: [.bacteria, .dirtStained],
            initialTeeth: applyStates([
                "T02": .dirtStained, "T03": .bacteria, "T06": .bacteria,
                "T07": .dirtStained, "T10": .bacteria, "T11": .dirtStained
            ])
        )
    }

    public static func createFatima() -> CharacterModel {
        CharacterModel(
            id: "char_14_fatima",
            name: "Fatima",
            gender: "female",
            skinToneHex: "#B87B4C",
            hairColorHex: "#1F2937",
            shirtColorHex: "#00ACC1",
            description: "Loves ice pops. She has sensitive teeth with hardened tartar deposits around her gums.",
            dentalProblems: [.calculus, .dirtStained],
            initialTeeth: applyStates([
                "T01": .calculus, "T02": .dirtStained, "T03": .calculus,
                "T05": .calculus, "T06": .dirtStained, "T08": .calculus,
                "T09": .dirtStained, "T11": .calculus, "T12": .dirtStained
            ])
        )
    }

    public static func createSam() -> CharacterModel {
        CharacterModel(
            id: "char_15_sam",
            name: "Sam",
            gender: "male",
            skinToneHex: "#FCD5B5",
            hairColorHex: "#C2593F",
            shirtColorHex: "#2E7D32",
            description: "Drinks too much soda. The acid eroded his enamel, creating small cavity spots across front teeth.",
            dentalProblems: [.bacteria, .dirtStained],
            initialTeeth: applyStates([
                "T01": .dirtStained, "T02": .bacteria, "T04": .bacteria,
                "T05": .dirtStained, "T08": .bacteria, "T09": .dirtStained,
                "T11": .bacteria, "T12": .dirtStained
            ])
        )
    }

    public static func createOliver() -> CharacterModel {
        CharacterModel(
            id: "char_16_oliver",
            name: "Oliver",
            gender: "male",
            skinToneHex: "#FEE3D4",
            hairColorHex: "#0F172A",
            shirtColorHex: "#B71C1C",
            description: "A boy with glasses experiencing toothache. Needs gentle anesthesia and cavity treatment.",
            dentalProblems: [.bacteria, .calculus, .dirtStained],
            initialTeeth: applyStates([
                "T01": .dirtStained, "T02": .bacteria, "T03": .calculus,
                "T04": .bacteria, "T06": .calculus, "T07": .dirtStained,
                "T08": .bacteria, "T09": .calculus, "T11": .dirtStained, "T12": .calculus
            ])
        )
    }

    public static func createZara() -> CharacterModel {
        CharacterModel(
            id: "char_17_zara",
            name: "Zara",
            gender: "female",
            skinToneHex: "#42221A",
            hairColorHex: "#050505",
            shirtColorHex: "#F59E0B",
            description: "Bit on a hard fruit pit and cracked a molar. Needs gentle extraction and a shiny new porcelain crown.",
            dentalProblems: [.necroticCracked, .calculus, .dirtStained],
            initialTeeth: applyStates([
                "T01": .dirtStained, "T03": .calculus, "T04": .necroticCracked,
                "T06": .calculus, "T07": .dirtStained, "T09": .calculus,
                "T11": .dirtStained, "T12": .calculus
            ])
        )
    }

    public static func createMateo() -> CharacterModel {
        CharacterModel(
            id: "char_18_mateo",
            name: "Mateo",
            gender: "male",
            skinToneHex: "#CF9563",
            hairColorHex: "#4A2E18",
            shirtColorHex: "#1E3A8A",
            description: "Has deep subgingival tartar and hidden cavities requiring careful scaling and treatment.",
            dentalProblems: [.calculus, .bacteria, .dirtStained],
            initialTeeth: applyStates([
                "T01": .calculus, "T02": .dirtStained, "T03": .bacteria,
                "T04": .calculus, "T06": .calculus, "T07": .dirtStained,
                "T08": .bacteria, "T09": .calculus, "T10": .dirtStained, "T11": .calculus
            ])
        )
    }

    public static func createLinh() -> CharacterModel {
        CharacterModel(
            id: "char_19_linh",
            name: "Linh",
            gender: "female",
            skinToneHex: "#FCE2C4",
            hairColorHex: "#111827",
            shirtColorHex: "#EC4899",
            description: "A friendly Asian girl with multiple dental needs: tartar buildup, cavities, and a loose front tooth.",
            dentalProblems: [.necroticCracked, .bacteria, .calculus, .dirtStained],
            initialTeeth: applyStates([
                "T01": .dirtStained, "T02": .bacteria, "T03": .calculus,
                "T04": .necroticCracked, "T06": .calculus, "T07": .dirtStained,
                "T08": .bacteria, "T09": .calculus, "T11": .dirtStained, "T12": .calculus
            ])
        )
    }

    public static func createArthur() -> CharacterModel {
        CharacterModel(
            id: "char_20_arthur",
            name: "Captain Arthur",
            gender: "male",
            skinToneHex: "#B07A4B",
            hairColorHex: "#F3F4F6",
            shirtColorHex: "#0F172A",
            description: "An old sea captain with thick calculus, two decayed teeth, and fishbone debris trapped in teeth.",
            dentalProblems: [.necroticCracked, .calculus, .dirtStained],
            initialTeeth: applyStates([
                "T01": .calculus, "T02": .dirtStained, "T03": .calculus,
                "T04": .necroticCracked, "T05": .necroticCracked, "T06": .calculus,
                "T07": .calculus, "T08": .dirtStained, "T09": .calculus,
                "T10": .dirtStained, "T11": .calculus, "T12": .calculus
            ])
        )
    }
}
