//
//  Atomic.swift
//  JoySpring
//
//  Created by Vlad Sys on 23.11.24.
//

import Foundation

public final class Atomic <T> {

    // mutex for locking
    private var lockable: Lockable

    // private backing var for the value
    private var _value: T

    /// Atomically get or set the stored value
    public var value: T {
        get {
            return map { $0 }
        }
        set {
            swap(newValue)
        }
    }

    /// Initialise a new Atomic store with a provided initial value
    /// - Parameter value: the value to initialise the atomic store with
    /// - Parameter lock: an optional item conforming to the Lockable protocol
    /// that defaults to a Mutex class
    /// - Returns: an Atomic store
    public init(_ value: T, lock: Lockable? = nil) {
        self._value = value
        self.lockable = lock ?? Atomic.make()
    }

    /// Atomically perform a closure with the current value of the atomic store
    /// - Parameter closure: the closure to perform
    public func withValue(_ closure: (T) -> Void) {
        self.lockable.performWhileLocked {
            closure(self._value)
        }
    }

    /// Atomically execute a closure passing in the current value and replacing
    /// the stored value with the result.
    /// - Parameter closure: a closure to perform with the original value that
    /// will return a new value to store
    /// - Returns: the original value
    @discardableResult
    public func modify(_ closure: (T) -> T) -> T {
        var originalValue: T?
        self.lockable.performWhileLocked {
            originalValue = self._value
            self._value = closure(self._value)
        }
        return originalValue!
    }

    /// Atomically swap the stored value with another value
    /// - Parameter newValue: the new value to store
    /// - Returns: the original value
    @discardableResult
    public func swap(_ newValue: T) -> T {
        return self.modify { _ in newValue }
    }

    /// Atomically map the currently stored value to a value of type R
    /// - Parameter closure: a closure that will map the currently stored value
    /// to a new value of type R
    /// - Returns: the result of the closure
    @discardableResult
    public func map<R>(_ closure: (T) -> R) -> R {
        var returnValue: R?
        self.lockable.performWhileLocked {
            returnValue = closure(self._value)
        }
        return returnValue!
    }

    /// Returns `os_unfair_lock` on supported platforms, with pthread mutex as the fallback.
    private static func make() -> Lockable {
        if #available(*, iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0) {
            return UnfairLock()
        }
        return PthreadLock()
    }
}

@available(iOS 10.0, *)
@available(macOS 10.12, *)
@available(tvOS 10.0, *)
@available(watchOS 3.0, *)
public final class UnfairLock {
    fileprivate let _lock: os_unfair_lock_t

    public init() {
        _lock = .allocate(capacity: 1)
        _lock.initialize(to: os_unfair_lock())
    }

    deinit {
        _lock.deinitialize(count: 1)
        _lock.deallocate()
    }
}

// ----------------------------------------------------------------------------
// MARK: - @protocol Lockable
// ----------------------------------------------------------------------------

@available(iOS 10.0, *)
@available(macOS 10.12, *)
@available(tvOS 10.0, *)
@available(watchOS 3.0, *)
extension UnfairLock: Lockable {
    /// lock the unfair lock and block other threads from accessing until unlocked
    public func lock() {
        os_unfair_lock_lock(_lock)
    }

    /// lock the unfair lock if it is not already locked and block other threads from accessing until unlocked
    public func tryLock() -> Bool {
        return os_unfair_lock_trylock(_lock)
    }

    /// unlock the unfair lock and allow other threads access once again
    public func unlock() {
        os_unfair_lock_unlock(_lock)
    }
}

public final class PthreadLock {
    fileprivate let _lock: UnsafeMutablePointer<pthread_mutex_t>

    public init(recursive: Bool = false) {
        _lock = .allocate(capacity: 1)
        _lock.initialize(to: pthread_mutex_t())

        let attr = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 1)
        attr.initialize(to: pthread_mutexattr_t())
        pthread_mutexattr_init(attr)

        defer {
            pthread_mutexattr_destroy(attr)
            attr.deinitialize(count: 1)
            attr.deallocate()
        }

        // Darwin pthread for 32-bit ARM somehow returns `EAGAIN` when
        // using `trylock` on a `PTHREAD_MUTEX_ERRORCHECK` mutex.
#if DEBUG && !arch(arm)
        pthread_mutexattr_settype(attr, Int32(recursive ? PTHREAD_MUTEX_RECURSIVE : PTHREAD_MUTEX_ERRORCHECK))
#else
        pthread_mutexattr_settype(attr, Int32(recursive ? PTHREAD_MUTEX_RECURSIVE : PTHREAD_MUTEX_NORMAL))
#endif

        let status = pthread_mutex_init(_lock, attr)
        assert(status == 0, "Unexpected pthread mutex error code: \(status)")
    }

    deinit {
        let status = pthread_mutex_destroy(_lock)
        assert(status == 0, "Unexpected pthread mutex error code: \(status)")

        _lock.deinitialize(count: 1)
        _lock.deallocate()
    }
}

// ----------------------------------------------------------------------------
// MARK: - @protocol Lockable
// ----------------------------------------------------------------------------

extension PthreadLock: Lockable {
    /// lock the mutex and block other threads from accessing until unlocked
    public func lock() {
        let status = pthread_mutex_lock(_lock)
        assert(status == 0, "Unexpected pthread mutex error code: \(status)")
    }

    /// lock the mutex if it is not already locked and block other threads from accessing until unlocked
    public func tryLock() -> Bool {
        let status = pthread_mutex_trylock(_lock)
        switch status {
        case 0:
            return true

        case EBUSY:
            return false

        default:
            assertionFailure("Unexpected pthread mutex error code: \(status)")
            return false
        }
    }

    /// unlock the mutex and allow other threads access once again
    public func unlock() {
        let status = pthread_mutex_unlock(_lock)
        assert(status == 0, "Unexpected pthread mutex error code: \(status)")
    }
}
