
import Foundation
import RealmSwift

protocol SettingsModuleOutput: AnyObject {
    func resetUpdate()
}

protocol SettingsViewInput: AnyObject {
    func update(_ model: SettingsModel)
}

public protocol SettingsViewOutput {
    func viewIsReady()
    func prepareInterval(_ interval: String)
    func prepareSelectedRes(index: Int)
    func prepareRepeatedRequestEnable(_ bool: Bool)
    func clearCache()
}

public protocol SettingsCommonOutput: AnyObject {
}

public protocol SettingsInteractorInput {
    func loadData()
    func setInterval(interval: String)
    func setSelectedRes(index: Int)
    func setRepeatedRequestEnable(bool: Bool)
    func cleanCache()
}

protocol SettingsInteractorOutput: AnyObject {
    func setModel(_ model: SettingsModel)
    func confirm()
}

protocol SettingsModuleInput: AnyObject {
    // ...
}

protocol SettingsRouterInput: BaseRouterInput {
}
