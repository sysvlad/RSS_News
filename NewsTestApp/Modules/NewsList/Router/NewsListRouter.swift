import UIKit

final class NewsListRouter: BaseRouter {
}

// MARK: - NewsListRouterInput

extension NewsListRouter: NewsListRouterInput {
// MARK: - Methods
    
    func showSettings(
        with dataStorage: SettingsDataStorage,
        moduleOutput: SettingsModuleOutput?
    ) {
        let vc = SettingsWireframe().initSettingsViewController(
            dataStorage: dataStorage,
            moduleOutput: moduleOutput
        )
        show(vc)
    }
}
