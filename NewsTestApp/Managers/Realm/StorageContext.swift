//
//  StorageContext.swift
//  NewsTestApp
//
//  Created by Vlad Sys on 12.12.24.
//

import Foundation
import RealmSwift

struct Sorted {
    var key: String
    var ascending: Bool = true
}

/*
 Operations on context
 */
protocol StorageContext {
    /*
     Create a new object with default values
     return an object that is conformed to the `Storable` protocol
     */
    func create<T: Object>(_ model: T.Type, completion: @escaping ((T) -> Void)) throws
    /*
     Save an object that is conformed to the `Storable` protocol
     */
    func save(object: Object) throws
    /*
     Update an object that is conformed to the `Storable` protocol
     */
    func update(block: @escaping () -> ()) throws
    /*
     Delete an object that is conformed to the `Storable` protocol
     */
    func delete(object: Object) throws
    /*
     Delete all objects that are conformed to the `Storable` protocol
     */
    func deleteAll<T: Object>(_ model: T.Type) throws
    /*
     Return a list of objects that are conformed to the `Storable` protocol
     */
    func fetch<T: Object>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted?, completion: (([T]) -> ()))
    
    func fetchCollection<T: Object>(
        _ model: T.Type,
        predicate: NSPredicate?,
        sorted: Sorted?
    ) -> Results<T>?
}
