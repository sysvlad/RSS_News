import Foundation
import UIKit
import RealmSwift

final class SettingsPresenter {

// MARK: - Properties

    weak var view: SettingsViewInput!
    var interactor: SettingsInteractorInput!
    var router: SettingsRouterInput!
    weak var moduleOutput: SettingsModuleOutput?

// MARK: - Private Methods


// MARK: - Constants

    private enum Constants {
    }

// MARK: - Variables

}

// MARK: - FirstEmissionStep1ViewOutput
extension SettingsPresenter: SettingsViewOutput {

// MARK: - Methods

    func viewIsReady() {
        interactor.loadData()
    }
    
    func prepareInterval(_ interval: String) {
        interactor.setInterval(interval: interval)
    }
    
    func prepareSelectedRes(index: Int) {
        interactor.setSelectedRes(index: index)
    }
    
    func prepareRepeatedRequestEnable(_ bool: Bool) {
        interactor.setRepeatedRequestEnable(bool: bool)
    }

    func clearCache() {
        interactor.cleanCache()
    }
}

// MARK: - SettingsInteractorOutput

extension SettingsPresenter: SettingsInteractorOutput {
// MARK: - Methods
    
    func setModel(_ model: SettingsModel) {
        view.update(model)
    }
    
    func confirm() {
        moduleOutput?.resetUpdate()
    }
}
