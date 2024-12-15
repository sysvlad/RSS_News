//
//  RepeatedRequestsService.swift
//  JoySpring
//
//  Created by Vlad Sys on 23.11.24.
//

import UIKit

final class RepeatedRequestsModel {

// MARK: - Construction

    init(
        timer: TimerServiceProtocol?,
        repeatedTask: Task<Void, Error>? = nil
    ) {
        self.timer = timer
        self.repeatedTask = repeatedTask
    }

// MARK: - Properties

    var timer: TimerServiceProtocol?
    var repeatedTask: Task<Void, Error>?
}

protocol RepeatedRequestsServiceProtocol: AnyObject {

    // Manual:
    // Inject service to ViewController, interactor (if needed in presenter and service).
    // In ViewController you have to add observers( they check app state).
    // In interactor have to startUpdate timer (with key) and add request to this key
    // and then you can stop timer where it needed and restart it for key.
    // Restart timer save completion block for key and it can repeat to update this block.

    func addLifeCycleObservers(viewController: UIViewController)
    func removeLifeCycleObservers()
    func startUpdate(
        for key: String,
        refreshTime: Double,
        firstFireTimeInterval: Double?,
        completion: @escaping VoidBlock
    )
    func restartUpdate(
        for key: String,
        firstFireTimeInterval: TimeInterval?
    )
    func stopUpdates()
    func stopUpdateAndBlockNewRequests(for key: String)
    func stopUpdateWithoutBlockingNewRequests(for key: String)

    func setRepeatedRequest(
        for key: String,
        repeatedTask: Task<Void, Error>?
    )
    func cancelRepeatedRequest(for key: String)

    func getRequestsAllowed() -> Bool
    func setCanRestartUpdate(_ value: Bool)
    func removeRequestFromDictionary(for key: String)
}

extension RepeatedRequestsServiceProtocol {
    func startUpdate(
        for key: String,
        refreshTime: Double,
        firstFireTimeInterval: Double? = nil,
        completion: @escaping VoidBlock
    ) {
        startUpdate(
            for: key,
            refreshTime: refreshTime,
            firstFireTimeInterval: firstFireTimeInterval,
            completion: completion
        )
    }

    func restartUpdate(
        for key: String,
        firstFireTimeInterval: TimeInterval? = nil
    ) {
        restartUpdate(
            for: key,
            firstFireTimeInterval: firstFireTimeInterval
        )
    }

    func setRepeatedRequest(
        for key: String,
        repeatedTask: Task<Void, Error>? = nil
    ) {
        setRepeatedRequest(
            for: key,
            repeatedTask: repeatedTask
        )
    }
}

class RepeatedRequestsService {

// MARK: - Construction

    init() {}

    deinit {
        stopUpdates()
    }

// MARK: - Private Methods

    private func registerApplicationNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(RepeatedRequestsService.didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(RepeatedRequestsService.willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    private func unregisterApplicationNotification() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    private func restartTimer(
        for key: String,
        firstFireTimeInterval: TimeInterval? = nil
    ) {
        requestsDictionary.value[key]?.timer?.restartTimer(firstFireTimeInterval: firstFireTimeInterval)
    }

    private func stopTimer(for key: String) {
        requestsDictionary.value[key]?.timer?.stopTimer()
    }

    private func setRepeatedRequestsCancel() {
        requestsDictionary.value.forEach {
            $0.value.repeatedTask?.cancel()
        }
    }

    private func setRepeatedRequestsCancel(for key: String) {
        requestsDictionary.value[key]?.repeatedTask?.cancel()
    }

    @objc
    private func didBecomeActive() {
        if UIViewController.visibleViewController == viewController {
            restartAllUpdates()
        }
    }

    @objc
    private func willResignActive() {
        stopAllUpdates()
    }

    private func stopAllUpdates() {
        areRequestsAllowed.swap(false)
        setRepeatedRequestsCancel()
        requestsDictionary.value.forEach {
            stopTimer(for: $0.key)
        }
    }

    private func restartAllUpdates() {
        areRequestsAllowed.swap(true)
        guard canRestartUpdate.value else {
            return
        }

        requestsDictionary.value.forEach {
            $0.value.timer?.restartTimer(firstFireTimeInterval: .zero)
        }
    }

// MARK: - Variables

    private weak var viewController: UIViewController?
    private var requestsDictionary: Atomic<[String: RepeatedRequestsModel]> = Atomic([:])
    private var areRequestsAllowed: Atomic<Bool> = Atomic(true)
    private var canRestartUpdate: Atomic<Bool> = Atomic(true)
}

// MARK: - RepeatedRequestsServiceProtocol

extension RepeatedRequestsService: RepeatedRequestsServiceProtocol {

    // Observers to keep track of the controller when it did Become Active or will Resign Active
    func  addLifeCycleObservers(viewController: UIViewController) {
        self.viewController = viewController
        restartAllUpdates()
        registerApplicationNotification()
    }

    func removeLifeCycleObservers() {
        stopAllUpdates()
        unregisterApplicationNotification()
    }

    // Start timer for current key in dictionary
    func startUpdate(
        for key: String,
        refreshTime: Double,
        firstFireTimeInterval: Double? = nil,
        completion: @escaping VoidBlock
    ) {
        requestsDictionary.value[key] = RepeatedRequestsModel(timer: TimerService())
        stopTimer(for: key)
        requestsDictionary.value[key]?.timer?.startTimer(
            refreshTime,
            firstFireTimeInterval: firstFireTimeInterval
        ) {
            completion()
        }
    }

    // Restart timer fore current key
    func restartUpdate(
        for key: String,
        firstFireTimeInterval: TimeInterval? = nil
    ) {
        areRequestsAllowed.swap(true)
        restartTimer(
            for: key,
            firstFireTimeInterval: firstFireTimeInterval
        )
    }

    // Cancel all requests in service and nullify timer
    func stopUpdates() {
        requestsDictionary.value.forEach {
            setRepeatedRequestsCancel(for: $0.key)
            stopTimer(for: $0.key)
            setRepeatedRequestsCancel(for: $0.key)
        }
    }

    func stopUpdateAndBlockNewRequests(for key: String) {
        areRequestsAllowed.swap(false)
        setRepeatedRequestsCancel(for: key)
        stopTimer(for: key)
        setRepeatedRequestsCancel(for: key)
    }

    func stopUpdateWithoutBlockingNewRequests(for key: String) {
        setRepeatedRequestsCancel(for: key)
        stopTimer(for: key)
        setRepeatedRequestsCancel(for: key)
    }

    // IMPORTANT! set request here after startUpdate
    func setRepeatedRequest(
        for key: String,
        repeatedTask: Task<Void, Error>?
    ) {
        requestsDictionary.value[key]?.repeatedTask = repeatedTask
    }

    func cancelRepeatedRequest(for key: String) {
        setRepeatedRequestsCancel(for: key)
    }

    // Set flag state for starting requests
    func setRequestsAllowed(_ value: Bool) {
        areRequestsAllowed.swap(value)
    }

    func getRequestsAllowed() -> Bool {
        return areRequestsAllowed.value
    }

    // Set condition for allowing restart update
    func setCanRestartUpdate(_ value: Bool) {
        canRestartUpdate.swap(value)
    }

    func removeRequestFromDictionary(for key: String) {
        requestsDictionary.value[key] = nil
    }
}
