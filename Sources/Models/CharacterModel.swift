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
            description: "Cậu bé năng động hay quên chải răng, răng bám nhiều vết bẩn đồ ngọt và vôi răng dày.",
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
            description: "Cô bé thích ăn kẹo dẻo ban đêm, có 2 răng cửa sâu nặng bị quái vật vi khuẩn tấn công.",
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
            description: "Cậu bé thích cắn đá lạnh, men răng bị ố bẩn và bám vôi răng kẽ lợi.",
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
            description: "Cô bé cá tính có răng khấp khểnh, cần vệ sinh tẩy mảng bám và lấy cao răng.",
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
            description: "Bé gái bị sâu răng và viêm nướu, có vi khuẩn đục khoét men răng cần điều trị triệt để.",
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
            name: "Bác Ben",
            gender: "male",
            skinToneHex: "#C68642",
            hairColorHex: "#E0E0E0",
            shirtColorHex: "#212121",
            description: "Bác giáo sư đãng trí có 2 răng lung lay hoại tử cần nhổ bỏ, trồng răng sứ và cạo sạch vôi răng.",
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
            description: "Bé trai 5 tuổi thích ăn mứt dâu tây, răng cửa dính nhiều mảng bám ngọt màu đỏ cam.",
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
            description: "Bé gái thích uống trà mật ong ấm, có mảng ố vàng trên men răng và một ít vôi răng nhẹ.",
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
            description: "Cậu bé mê ăn kẹo dẻo hoa quả, kẹo dính chặt kẽ răng tạo mảng bám thức ăn dày.",
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
            description: "Cô bé thích sinh tố việt quất, men răng tím sẫm và có cao răng kẽ dưới.",
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
            description: "Cậu bé lén ăn socola đen trước khi ngủ, có 2 răng hàm sâu có vi khuẩn đỏ đục khoét.",
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
            description: "Bé gái năng động hay quên dùng chỉ nha khoa, vôi răng dày bám cổ răng kèm 1 ổ sâu.",
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
            description: "Cậu bé nghịch ngợm cắn phải kẹo cứng, mẻ men răng và vi khuẩn xâm nhập vào ngà răng.",
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
            description: "Bé gái thích ăn kem que lạnh buốt, răng nhạy cảm kèm theo mảng bám vôi cứng chân răng.",
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
            description: "Cậu bé mê nước ngọt có gas, acid làm mòn men răng tạo nhiều ổ sâu nhỏ quanh răng cửa.",
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
            description: "Bé trai đeo kính cận bị sâu răng nặng gây đau nhức tủy, cần tiêm tê và nạo sạch vi khuẩn sâu.",
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
            description: "Bé gái cá tính cắn phải hạt quả cứng làm nứt vỡ 1 chiếc răng hàm hoại tử, cần nhổ và cấy răng sứ.",
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
            description: "Cậu bé có vôi răng bám sâu dưới nướu và một răng sâu ẩn ngầm, cần cạo vôi và điều trị toàn diện.",
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
            description: "Bé gái châu Á bị tổ hợp đa bệnh lý: vừa bám vôi răng, vừa có răng sâu và một răng cửa lung lay.",
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
            name: "Bác Arthur",
            gender: "male",
            skinToneHex: "#B07A4B",
            hairColorHex: "#F3F4F6",
            shirtColorHex: "#0F172A",
            description: "Thuyền trưởng già đi biển lâu năm, cao răng đóng khối, 2 răng hoại tử và dị vật xương cá kẹt kẽ răng.",
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
