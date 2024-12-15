
import UIKit

final class SettingsWireframe {
// MARK: - Construction

    init() {}

// MARK: - Methods

    func initSettingsViewController(
        dataStorage: SettingsDataStorage,
        moduleOutput: SettingsModuleOutput?
    ) -> SettingsViewController {
		if self.viewController == nil {
            self.viewController = SettingsViewController()
			configurator.configureModuleForViewInput(
                viewInput: viewController,
                dataStorage: dataStorage,
                moduleOutput: moduleOutput
            )
		}
		return viewController!
	}

// MARK: - Variables

    private var viewController: SettingsViewController?
    private let configurator = SettingsModuleConfigurator()
}
