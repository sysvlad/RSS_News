
import Foundation
import RealmSwift

struct SettingsModel {
// MARK: - Construction

    init(resValues: [String], resSelected: Int, periodUpdateIsOn: Bool, interval: String) {
        self.resValues = resValues
        self.resSelected = resSelected
        self.periodUpdateIsOn = periodUpdateIsOn
        self.interval = interval
    }

// MARK: Properties

    let resValues: [String]
    let resSelected: Int
    let periodUpdateIsOn: Bool
    let interval: String
}
