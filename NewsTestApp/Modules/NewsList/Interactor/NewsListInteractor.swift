
import Foundation
import RealmSwift

final class NewsListInteractor {
// MARK: - Construction

    init(
        output: NewsListInteractorOutput,
        dataStorage: NewsListDataStorage,
        networkService: NetworkServiceProtocol,
        repeatedService: RepeatedRequestsServiceProtocol,
        storage: StorageContext = try! RealmStorageContext()
    ) {
        self.output = output
        self.dataStorage = dataStorage
        self.networkService = networkService
        self.repeatedService = repeatedService
        self.storage = storage
    }

// MARK: - Properties

    private(set) weak var output: NewsListInteractorOutput!

// MARK: - Methods


// MARK: - Private Methods
    
    @MainActor
    private func saveToRealm(items: [RSSItem]) async {
        var oldObjcts: [RealmRSSFeedMo] = []
        storage.fetch(RealmRSSFeedMo.self, predicate: nil, sorted: nil) { feeds in
            oldObjcts = feeds
        }
        
        let newUniqResponseItems = items.filter { responseItem in
            !oldObjcts.contains { realmObj in
                responseItem.title == realmObj.title
                && responseItem.description == realmObj.descriptionValue
                && responseItem.enclosure == realmObj.enclosure
                && responseItem.pubDate.getDate() == realmObj.pubDate
                && responseItem.resource == realmObj.resource
            }
        }
        
        await newUniqResponseItems.asyncForEach { item in
            await withCheckedContinuation { continuation in
                try? storage.create(RealmRSSFeedMo.self) { content in
                    content.title = item.title
                    content.descriptionValue = item.description
                    content.pubDate = item.pubDate.getDate() ?? Date()
                    content.enclosure = item.enclosure
                    content.resource = item.resource
                    continuation.resume()
                }
            }
        }
        objects = self.storage.fetchCollection(RealmRSSFeedMo.self, predicate: nil, sorted: Sorted(key: "pubDate"))
    }

    @MainActor
    private func setObserver() {
        self.notificationToken = objects.observe { [weak self] (changes: RealmCollectionChange) in
            guard let self else {
                return
            }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                output.setModels(objects)
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                let model = NewsListModel(
                    models: objects,
                    insertions: insertions,
                    deletions: deletions,
                    modifications: modifications
                )
                output.update(model)
                
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
            }
        }
    }
    
    private func executeGetDataRepeated() {
        repeatRssTask?.cancel()
        repeatRssTask = Task { @MainActor in
            let urls: [String] = [AppUrls.newsUrl, AppUrls.issueUrl]
            var responses: [RSSItem] = []
            try await urls.asyncForEach {
                let response = try await networkService.getResponse(url: $0)
                responses.append(contentsOf: response)
            }
            guard repeatedService.getRequestsAllowed() else {
                return
            }
            
            let resCurrentValue = UserDefaultsManager.shared.selectedResValue
            if resCurrentValue == "All" {
                resEnum = .all
            } else {
                resEnum = .res(resCurrentValue)
            }

            responses.forEach { item in
                if !resourses.contains(item.resource) {
                    resourses.append(item.resource)
                }
            }
            _ = await saveToRealm(items: responses)
            setObserver()
            if UserDefaultsManager.shared.isRepeatedRequestEnable {
                repeatedRequests(fireTime: nil)
            }
        }
        
        repeatedService.setRepeatedRequest(
            for: RequestsServiceKeyType.rss.rawValue,
            repeatedTask: repeatRssTask
        )
    }

// MARK: - Constants

    private enum Constants {
        
    }

// MARK: - Variables

    private let dataStorage: NewsListDataStorage
    private let networkService: NetworkServiceProtocol
    private let repeatedService: RepeatedRequestsServiceProtocol
    private var storage: StorageContext!
    var objects: Results<RealmRSSFeedMo>! {
        didSet {
            switch resEnum {
            case .all:
                objects = self.storage.fetchCollection(
                    RealmRSSFeedMo.self,
                    predicate: nil,
                    sorted: Sorted(key: "pubDate")
                )
            case .res(let resString):
                let predicate = NSPredicate(format: "resource = %@", resString)
                self.objects = objects.filter(predicate)
            }
        }
    }
    private var resEnum = Resourses.all
    private var notificationToken: NotificationToken?
    private var resourses: [String] = []
    private var repeatRssTask: Task<Void, Error>?
}

// ----------------------------------------------------------------------------

extension NewsListInteractor: NewsListInteractorInput {

// MARK: - Methods
    
    func getData() {
        Task { @MainActor in
            let urls: [String] = [AppUrls.newsUrl, AppUrls.issueUrl]
            var responses: [RSSItem] = []
            try await urls.asyncForEach {
                let response = try await networkService.getResponse(url: $0)
                responses.append(contentsOf: response)
            }
            
            responses.forEach { item in
                if !resourses.contains(item.resource) {
                    resourses.append(item.resource)
                }
            }
            
            let resCurrentValue = UserDefaultsManager.shared.selectedResValue
            if resCurrentValue == "All" {
                resEnum = .all
            } else {
                resEnum = .res(resCurrentValue)
            }

            _ = await saveToRealm(items: responses)
            setObserver()
            repeatedRequests(fireTime: nil)
        }
    }
    
    func repeatedRequests(fireTime: TimeInterval?) {
        let refreshTime: TimeInterval = UserDefaultsManager.shared.repeatTimeInterval
        repeatedService.startUpdate(
            for: RequestsServiceKeyType.rss.rawValue,
            refreshTime: refreshTime
        ) { [weak self] in
            guard let self else {
                return
            }

            self.executeGetDataRepeated()
        }
    }

    func setItemSelected(id: String) {
        let predicate = NSPredicate(format: "id = %@", id)
        storage.fetch(RealmRSSFeedMo.self, predicate: predicate, sorted: nil) { feeds in
            if let feed = feeds.first {
                try! storage.update {
                    feed.isSelected = !feed.isSelected
                    feed.isReaded = true
                }
            }
        }
    }

    func makeSettingsDataStorage() {
        let dataStorage = SettingsDataStorage(resourses: self.resourses)
        output.goToSettings(dataStorage)
    }
}
