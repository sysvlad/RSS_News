
import Foundation
import RealmSwift

protocol NewsListViewInput: AnyObject {
    func initial(_ models: Results<RealmRSSFeedMo>?)
    func update(_ models: NewsListModel)
}

public protocol NewsListViewOutput {
    func viewIsReady()
    func setItemSelected(id: String)
    func prepareSettings()
}

public protocol NewsListCommonOutput: AnyObject {
}

public protocol NewsListInteractorInput {
    func getData()
    func repeatedRequests(fireTime: TimeInterval?)
    func setItemSelected(id: String)
    func makeSettingsDataStorage()
}

protocol NewsListInteractorOutput: AnyObject {
    func setModels(_ models: Results<RealmRSSFeedMo>?)
    func update(_ model: NewsListModel)
    func goToSettings(_ dataStorage: SettingsDataStorage)
}

protocol NewsListModuleInput: AnyObject {
    // ...
}

protocol NewsListRouterInput: BaseRouterInput {
    func showSettings(
        with dataStorage: SettingsDataStorage,
        moduleOutput: SettingsModuleOutput?
    )
}
