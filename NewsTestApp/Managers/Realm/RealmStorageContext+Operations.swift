//
//  RealmStorageContext+Operations.swift
//  NewsTestApp
//
//  Created by Vlad Sys on 12.12.24.
//

import Foundation
import RealmSwift

extension RealmStorageContext {
    func create<T: Object>(_ model: T.Type, completion: @escaping ((T) -> Void)) throws {
        guard let realm = self.realm else {
            throw NSError()
        }
        
        try self.safeWrite {
            let newObject = realm.create(model, value: [], update: .modified) 
            completion(newObject)
        }
    }
    
    func save(object: Object) throws {
        guard let realm = self.realm else {
            throw NSError()
        }
        
        try self.safeWrite {
            realm.add(object)
        }
    }
    
    func update(block: @escaping () -> Void) throws {
        try self.safeWrite {
            block()
        }
    }
}

extension RealmStorageContext {
    func delete(object: Object) throws {
        guard let realm = self.realm else {
            throw NSError()
        }
        
        try self.safeWrite {
            realm.delete(object)
        }
    }
    
    func deleteAll<T : Object>(_ model: T.Type) throws {
        guard let realm = self.realm else {
            throw NSError()
        }
        
        try self.safeWrite {
            let objects = realm.objects(model)
            
            for object in objects {
                realm.delete(object)
            }
        }
    }
    
    func reset() throws {
        guard let realm = self.realm else {
            throw NSError()
        }
        
        try self.safeWrite {
            realm.deleteAll()
        }
    }
}

extension RealmStorageContext {
    func fetch<T: Object>(_ model: T.Type,
                            predicate: NSPredicate? = nil,
                            sorted: Sorted? = nil,
                            completion: (([T]) -> Void)) {
        var objects = self.realm?.objects(model)
        
        if let predicate = predicate {
            objects = objects?.filter(predicate)
        }
        
        if let sorted = sorted {
            objects = objects?.sorted(byKeyPath: sorted.key, ascending: sorted.ascending)
        }
        
        var accumulate: [T] = [T]()
        for object in objects! {
            accumulate.append(object as! T)
        }
        
        completion(accumulate)
    }
    
    func fetchCollection<T: Object>(
        _ model: T.Type,
        predicate: NSPredicate?,
        sorted: Sorted?
    ) -> Results<T>? {
        var objects = self.realm?.objects(model)
        
        if let predicate = predicate {
            objects = objects?.filter(predicate)
        }
        
        if let sorted = sorted {
            objects = objects?.sorted(byKeyPath: sorted.key, ascending: sorted.ascending)
        }
        
        return objects
    }
}
