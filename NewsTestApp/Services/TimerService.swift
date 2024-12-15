//
//  TimerService.swift
//  JoySpring
//
//  Created by Vlad Sys on 23.11.24.
//

import Foundation

public enum TimerServiceTimerState {
    case resumed
    case suspended
    case stopped
}

public protocol TimerServiceProtocol {

// MARK: - Methods

    func startTimer(_ timeInterval: TimeInterval, firstFireTimeInterval: TimeInterval?, closure: @escaping VoidBlock)
    func restartTimer(firstFireTimeInterval: TimeInterval?)
    func stopTimer()
    func suspendTimer()
    func resumeTimer()
    func getTimerState() -> TimerServiceTimerState
    func updateTimeInterval(_ timeInterval: TimeInterval)
    func setClosure()
}

extension TimerServiceProtocol {
    public func startTimer(_ timeInterval: TimeInterval, firstFireTimeInterval: TimeInterval? = nil, closure: @escaping VoidBlock) {
        startTimer(timeInterval, firstFireTimeInterval: firstFireTimeInterval, closure: closure)
    }

    public func restartTimer(firstFireTimeInterval: TimeInterval? = nil) {
        restartTimer(firstFireTimeInterval: firstFireTimeInterval)
    }
}

public final class TimerService: TimerServiceProtocol {

    public init() {}

// MARK: - Methods

    public func startTimer(_ timeInterval: TimeInterval, firstFireTimeInterval: TimeInterval? = nil, closure: @escaping VoidBlock) {
        self.timeInterval.swap(timeInterval)
        self.firstFireTimeInterval.swap(firstFireTimeInterval)
        self.closure.swap(closure)

        timer.swap(
            BackgroundThreadRepeatingTimer(
                timeInterval: timeInterval,
                firstFireTimeInterval: firstFireTimeInterval
            ) {
                closure()
            }
        )

        timer.value?.resume()
        state.swap(.resumed)
    }

    public func restartTimer(firstFireTimeInterval: TimeInterval? = nil) {
        guard let timeInterval = self.timeInterval.value,
              let closure = self.closure.value else {
            return
        }
        timer.swap(nil)
        state.swap(.stopped)

        if let currentFirstFireTimeInterval = firstFireTimeInterval {
            timer.swap(
                BackgroundThreadRepeatingTimer(
                    timeInterval: timeInterval,
                    firstFireTimeInterval: currentFirstFireTimeInterval
                ) {
                    closure()
                }
            )
        } else {
            timer.swap(
                BackgroundThreadRepeatingTimer(
                    timeInterval: timeInterval,
                    firstFireTimeInterval: self.firstFireTimeInterval.value
                ) {
                    closure()
                }
            )
        }

        timer.value?.resume()
        state.swap(.resumed)
    }

    public func stopTimer() {
        if timer.value != nil {
            timer.swap(nil)
        }

        state.swap(.stopped)
    }

    public func suspendTimer() {
        timer.value?.suspend()
        state.swap(.suspended)
    }

    public func resumeTimer() {
        timer.value?.resume()
        state.swap(.resumed)
    }

    public func getTimerState() -> TimerServiceTimerState {
        return state.value
    }

    public func updateTimeInterval(_ timeInterval: TimeInterval) {
        self.timeInterval.swap(timeInterval)
    }

    public func setClosure() {
        guard let closure = closure.value else {
            return
        }

        closure()
    }

// MARK: - Variables

    private var timer: Atomic<BackgroundThreadRepeatingTimer?> = Atomic(nil)

    private var state: Atomic<TimerServiceTimerState> = Atomic(.stopped)

    private var timeInterval: Atomic<TimeInterval?> = Atomic(nil)

    private var firstFireTimeInterval: Atomic<TimeInterval?> = Atomic(nil)

    private var closure: Atomic<VoidBlock?> = Atomic(nil)
}
