//
//  String.swift
//  NewsTestApp
//
//  Created by Vlad Sys on 9.12.24.
//

import Foundation

extension DateFormatter {
    static var transformToDate: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
        return dateFormatter
    }()
}

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
        return formatter.string(from: self)
    }
}

