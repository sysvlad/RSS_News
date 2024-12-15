
import UIKit

final class NewsListModuleConfigurator {
// MARK: - Construction

    init() {}

// MARK: - Methods

    func configureModuleForViewInput<UIViewController>(
        viewInput: UIViewController,
        dataStorage: NewsListDataStorage
    ) {
        if let viewController = viewInput as? NewsListViewController {
            configure(
                viewController: viewController,
                dataStorage: dataStorage
            )
        }
    }

// MARK: - Private Methods

    private func configure(
        viewController: NewsListViewController,
        dataStorage: NewsListDataStorage
    ) {
        let router = NewsListRouter(viewController: viewController)
        let presenter = NewsListPresenter()
        let repeatedService = RepeatedRequestsService()

        presenter.view = viewController
        presenter.router = router

        let interactor = NewsListInteractor(
            output: presenter,
            dataStorage: dataStorage, 
            networkService: NetworkService(),
            repeatedService: repeatedService
        )

        presenter.interactor = interactor
        viewController.output = presenter
        viewController.repeatedRequestsService = repeatedService
    }
}
