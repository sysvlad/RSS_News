
import UIKit

final class SettingsModuleConfigurator {
// MARK: - Construction

    init() {}

// MARK: - Methods

    func configureModuleForViewInput<UIViewController>(
        viewInput: UIViewController,
        dataStorage: SettingsDataStorage,
        moduleOutput: SettingsModuleOutput?
    ) {
        if let viewController = viewInput as? SettingsViewController {
            configure(
                viewController: viewController,
                dataStorage: dataStorage,
                moduleOutput: moduleOutput
            )
        }
    }

// MARK: - Private Methods

    private func configure(
        viewController: SettingsViewController,
        dataStorage: SettingsDataStorage,
        moduleOutput: SettingsModuleOutput?
    ) {
        let router = SettingsRouter(viewController: viewController)
        let presenter = SettingsPresenter()
        presenter.moduleOutput = moduleOutput
        let repeatedService = RepeatedRequestsService()

        presenter.view = viewController
        presenter.router = router

        let interactor = SettingsInteractor(
            output: presenter,
            dataStorage: dataStorage
        )

        presenter.interactor = interactor
        viewController.output = presenter
        viewController.repeatedRequestsService = repeatedService
    }
}
