//
//  Lockable.swift
//  JoySpring
//
//  Created by Vlad Sys on 23.11.24.
//

import Foundation

public protocol Lockable {

    /// lock as appropriate for the type
    func lock()

    /// lock as appropriate for the type if it is not already locked
    func tryLock() -> Bool

    /// unlock as appropriate for the type
    func unlock()

    /// perform
    func performWhileLocked(closure: () -> ())
}

extension Lockable {

    public func performWhileLocked(closure: () -> ()) {
        self.lock()
        defer { self.unlock() }
        closure()
    }
}
