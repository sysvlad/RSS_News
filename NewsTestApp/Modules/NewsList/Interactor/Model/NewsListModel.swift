
import Foundation
import RealmSwift

struct NewsListModel {
// MARK: - Construction

    init(models: Results<RealmRSSFeedMo>?, insertions: [Int], deletions: [Int], modifications: [Int]) {
        self.models = models
        self.insertions = insertions
        self.deletions = deletions
        self.modifications = modifications
    }

// MARK: Properties

    let models: Results<RealmRSSFeedMo>?
    let insertions: [Int]
    let deletions: [Int]
    let modifications: [Int]
}

enum Resourses{
    case all
    case res(String)
}

enum RequestsServiceKeyType: String {
    case rss
}
