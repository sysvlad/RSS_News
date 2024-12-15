//
//  RealmRSSFeedMo.swift
//  NewsTestApp
//
//  Created by Vlad Sys on 12.12.24.
//

import Foundation
import RealmSwift

/*
 Dummy protocol for Entities
 */
//protocol Storable {
//}
//extension Object: Storable {
//}

@objcMembers
class RealmRSSFeedMo: Object {
    dynamic var id: String = UUID().uuidString
    dynamic var title: String = ""
    dynamic var descriptionValue: String = ""
    dynamic var pubDate: Date = Date()
    dynamic var enclosure: String = ""
    dynamic var resource: String = ""
    dynamic var isSelected: Bool = false
    dynamic var isReaded: Bool = false
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? RealmRSSFeedMo {
            return self.title == object.title
            && self.descriptionValue == object.descriptionValue
            && self.pubDate == object.pubDate
            && self.enclosure == object.enclosure
            && self.resource == object.resource
        } else {
            return false
        }
    }
}
