
import UIKit

final class NewsListWireframe {
// MARK: - Construction

    init() {}

// MARK: - Methods

    func initNewsListViewController(dataStorage: NewsListDataStorage) -> NewsListViewController {
		if self.viewController == nil {
            self.viewController = NewsListViewController()
			configurator.configureModuleForViewInput(
                viewInput: viewController,
                dataStorage: dataStorage
            )
		}
		return viewController!
	}

// MARK: - Variables

    private var viewController: NewsListViewController?
    private let configurator = NewsListModuleConfigurator()
}
