import SwiftUI

public enum AppNavigationState {
    case splash
    case mainMenu
    case characterSelection
    case levelSelection
    case clinic(CharacterModel)
    case result(CharacterModel, Int, Int)
    case miniGameHub
    case miniGameHippo
    case miniGameFrog
    case miniGameLaser
    case miniGameBraces
}

@main
public struct DentistGameApp: App {
    @State private var navigationState: AppNavigationState = .splash
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var saveManager = SaveManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared

    private let characters = CharacterModel.createDefaultCharacters()

    public init() {}

    public var body: some Scene {
        WindowGroup {
            switch navigationState {
            case .splash:
                SplashView(
                    audioManager: audioManager,
                    localizationManager: localizationManager,
                    onEnterGame: {
                        navigationState = .mainMenu
                    }
                )

            case .mainMenu:
                MainMenuView(
                    audioManager: audioManager,
                    saveManager: saveManager,
                    localizationManager: localizationManager,
                    onStartGame: {
                        navigationState = .characterSelection
                    },
                    onOpenLevelSelect: {
                        navigationState = .levelSelection
                    },
                    onOpenMiniGames: {
                        navigationState = .miniGameHub
                    }
                )

            case .characterSelection:
                CharacterSelectionView(
                    characters: characters,
                    onSelectCharacter: { char in
                        navigationState = .clinic(char)
                    },
                    onOpenMiniGames: {
                        navigationState = .miniGameHub
                    },
                    onBack: {
                        navigationState = .mainMenu
                    }
                )

            case .levelSelection:
                LevelSelectionView(
                    audioManager: audioManager,
                    saveManager: saveManager,
                    localizationManager: localizationManager,
                    characters: characters,
                    onSelectCharacter: { char in
                        navigationState = .clinic(char)
                    },
                    onBack: {
                        navigationState = .mainMenu
                    }
                )

            case .clinic(let character):
                ClinicRoomView(
                    character: character,
                    onFinishTreatment: { score, stars in
                        let level = DifficultyLevel.getLevelForCharacter(characterId: character.id)
                        saveManager.recordGameResult(
                            levelId: level.rawValue,
                            characterId: character.id,
                            score: score,
                            stars: stars
                        )
                        navigationState = .result(character, score, stars)
                    },
                    onBack: {
                        audioManager.startBgm(named: "bgm_main_menu")
                        navigationState = .characterSelection
                    }
                )

            case .result(let character, let score, let stars):
                let nextLevelCharacter: CharacterModel? = {
                    switch character.id {
                    case "char_01_leo": return characters.first(where: { $0.id == "char_02_maya" })
                    case "char_02_maya": return characters.first(where: { $0.id == "char_03_kenji" })
                    case "char_03_kenji": return characters.first(where: { $0.id == "char_04_amara" })
                    case "char_04_amara": return characters.first(where: { $0.id == "char_05_mia" })
                    case "char_05_mia": return characters.first(where: { $0.id == "char_06_ben" })
                    case "char_06_ben": return nil
                    default: return nil
                    }
                }()

                ResultView(
                    character: character,
                    score: score,
                    stars: stars,
                    hasNextLevel: nextLevelCharacter != nil && saveManager.isLevelUnlocked(DifficultyLevel.getLevelForCharacter(characterId: nextLevelCharacter!.id).rawValue),
                    audioManager: audioManager,
                    localizationManager: localizationManager,
                    onReplay: {
                        navigationState = .clinic(character)
                    },
                    onNextLevel: {
                        if let nextChar = nextLevelCharacter {
                            navigationState = .clinic(nextChar)
                        } else {
                            navigationState = .mainMenu
                        }
                    },
                    onBackToMenu: {
                        audioManager.startBgm(named: "bgm_main_menu")
                        navigationState = .mainMenu
                    }
                )

            case .miniGameHub:
                MiniGameHubView(
                    audioManager: audioManager,
                    onSelectGame: { game in
                        switch game {
                        case .hippoFood: navigationState = .miniGameHippo
                        case .frogBug: navigationState = .miniGameFrog
                        case .bacteriaBlaster: navigationState = .miniGameLaser
                        case .fashionBraces: navigationState = .miniGameBraces
                        }
                    },
                    onBack: {
                        navigationState = .mainMenu
                    }
                )

            case .miniGameHippo:
                HippoFoodSortingView(
                    audioManager: audioManager,
                    onBack: {
                        navigationState = .miniGameHub
                    }
                )

            case .miniGameFrog:
                FrogBugCatchingView(
                    audioManager: audioManager,
                    onBack: {
                        navigationState = .miniGameHub
                    }
                )

            case .miniGameLaser:
                BacteriaLaserShooterView(
                    audioManager: audioManager,
                    onBack: {
                        navigationState = .miniGameHub
                    }
                )

            case .miniGameBraces:
                FashionBracesView(
                    audioManager: audioManager,
                    onBack: {
                        navigationState = .miniGameHub
                    }
                )
            }
        }
    }
}
