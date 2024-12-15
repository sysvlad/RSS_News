import Foundation
import UIKit
import RealmSwift

final class NewsListPresenter {

// MARK: - Properties

    weak var view: NewsListViewInput!
    var interactor: NewsListInteractorInput!
    var router: NewsListRouterInput!

// MARK: - Private Methods


// MARK: - Constants

    private enum Constants {
    }

// MARK: - Variables

}

// MARK: - FirstEmissionStep1ViewOutput
extension NewsListPresenter: NewsListViewOutput {

// MARK: - Methods

    func viewIsReady() {
        interactor.getData()
    }

    func setItemSelected(id: String) {
        interactor.setItemSelected(id: id)
    }

    func prepareSettings() {
        interactor.makeSettingsDataStorage()
    }
}

// MARK: - NewsListInteractorOutput

extension NewsListPresenter: NewsListInteractorOutput {
// MARK: - Methods
    
    func setModels(_ models: Results<RealmRSSFeedMo>?) {
        view.initial(models)
    }

    func update(_ model: NewsListModel) {
        view.update(model)
    }

    func goToSettings(_ dataStorage: SettingsDataStorage) {
        router.showSettings(
            with: dataStorage,
            moduleOutput: self
        )
    }
}

extension NewsListPresenter: SettingsModuleOutput {
    func resetUpdate() {
        interactor.repeatedRequests(fireTime: 0)
    }
}
