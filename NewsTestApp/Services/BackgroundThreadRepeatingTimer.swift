
import Foundation

// ----------------------------------------------------------------------------

// A Background Repeating Timer in Swift
// @link https://medium.com/over-engineering/a-background-repeating-timer-in-swift-412cecfd2ef9

/// RepeatingTimer mimics the API of DispatchSourceTimer but in a way that prevents
/// crashes that occur from calling resume multiple times on a timer that is
/// already resumed (noted by https://github.com/SiftScience/sift-ios/issues/52)

final class BackgroundThreadRepeatingTimer {

// MARK: - Constructor

    /// Create background repeating timer
    /// - Parameters:
    ///   - timeInterval: repeating time interval
    ///   - firstFireTimeInterval: 0 - to fire repeating timer immediately at first time. Be default - nil, timeInterval parameter is used
    ///   - eventHandler: block which is executed when timer is fired
    init(timeInterval: TimeInterval, firstFireTimeInterval: TimeInterval? = nil, eventHandler: (() -> Void)?) {
        self.timeInterval = Atomic(timeInterval)
        self.firstFireTimeInterval = Atomic(firstFireTimeInterval ?? timeInterval)
        self.eventHandler = Atomic(eventHandler)
    }

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler.swap(nil)
    }

// MARK: - Methods

    func resume() {
        if state.value == .resumed {
            return
        }
        state.swap(.resumed)
        timer.resume()
    }

    func suspend() {
        if state.value == .suspended {
            return
        }
        state.swap(.suspended)
        timer.suspend()
    }

// MARK: - Inner Types

    private enum State {
        case suspended
        case resumed
    }

// MARK: - Variables

    private lazy var timer: DispatchSourceTimer = {
        let result = DispatchSource.makeTimerSource()
        result.schedule(deadline: .now() + self.firstFireTimeInterval.value, repeating: self.timeInterval.value)
        result.setEventHandler(handler: { [weak self] in
            self?.eventHandler.value?()
        })

        // Done
        return result
    }()

    private let timeInterval: Atomic<TimeInterval>
    private let firstFireTimeInterval: Atomic<TimeInterval>
    private var eventHandler: Atomic<VoidBlock?> = Atomic(nil)
    private var state: Atomic<State> = Atomic(.suspended)
}
