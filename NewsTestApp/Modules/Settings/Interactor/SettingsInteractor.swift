
import Foundation
import Alamofire
import RealmSwift
import SDWebImage

final class SettingsInteractor {
    // MARK: - Construction
    
    init(
        output: SettingsInteractorOutput,
        dataStorage: SettingsDataStorage
    ) {
        self.output = output
        self.dataStorage = dataStorage
    }
    
    // MARK: - Properties
    
    private(set) weak var output: SettingsInteractorOutput!
    
    // MARK: - Methods
    
    
    // MARK: - Private Methods
    
    
    // MARK: - Constants
    
    private enum Constants {
        
    }
    
    // MARK: - Variables
    
    private let dataStorage: SettingsDataStorage
    private var resValues = ["All"]
}

// ----------------------------------------------------------------------------

extension SettingsInteractor: SettingsInteractorInput {

// MARK: - Methods
    
    func loadData() {
        dataStorage.resourses.forEach {
            if !resValues.contains($0) {
                resValues.append($0)
            }
        }
        let selectedRes = UserDefaultsManager.shared.selectedResValue
        let periodUpdateIsOn = UserDefaultsManager.shared.isRepeatedRequestEnable
        let interval = UserDefaultsManager.shared.repeatTimeInterval
        let selectedIndex = resValues.firstIndex(of: selectedRes) ?? 0
        let model = SettingsModel(
            resValues: resValues,
            resSelected: selectedIndex,
            periodUpdateIsOn: periodUpdateIsOn,
            interval: String(interval)
        )
        output.setModel(model)
    }
    
    func setInterval(interval: String) {
        if let doubleInterval = Double(interval) {
            UserDefaultsManager.shared.repeatTimeInterval = doubleInterval
        }
        loadData()
        output.confirm()
    }
    
    func setSelectedRes(index: Int) {
        let selected = resValues[index]
        UserDefaultsManager.shared.selectedResValue = selected
        loadData()
        output.confirm()
    }

    func setRepeatedRequestEnable(bool: Bool) {
        UserDefaultsManager.shared.isRepeatedRequestEnable = bool
        loadData()
        output.confirm()
    }

    func cleanCache() {
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        output.confirm()
    }
}
