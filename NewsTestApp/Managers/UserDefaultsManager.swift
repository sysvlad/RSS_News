//
//  UserDefaultsManager.swift
//  NewsTestApp
//
//  Created by Vlad Sys on 14.12.24.
//

import Foundation

class UserDefaultsManager {
    
    static let shared: UserDefaultsManager = UserDefaultsManager()
    
    private init() {}
    
    var repeatTimeInterval: Double {
        get {
            if UserDefaults.standard.double(forKey: Constants.repeatTimeInterval) == 0 {
                UserDefaults.standard.set(10, forKey: Constants.repeatTimeInterval)
            }
            return UserDefaults.standard.double(forKey: Constants.repeatTimeInterval)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.repeatTimeInterval)
        }
    }

    var isRepeatedRequestEnable: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constants.isRepeatedRequestCancel)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.isRepeatedRequestCancel)
        }
    }
    
    var selectedResValue: String {
        get {
            return UserDefaults.standard.string(forKey: Constants.selectedResValue) ?? "All"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.selectedResValue)
        }
    }
}

fileprivate extension UserDefaultsManager {

    enum Constants {
        static let repeatTimeInterval = "repeatTimeInterval"
        static let isRepeatedRequestCancel = "isRepeatedRequestCancel"
        static let selectedResValue = "selectedResValue"
    }
}
