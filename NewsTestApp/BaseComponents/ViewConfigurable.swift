//
//  ViewConfigurable.swift
//  JoySpring
//
//  Created by Vlad Sys on 2.09.24.
//

import Foundation

public protocol ViewConfigurable {
    // Add subviews settings and add subviews to parent
    func configureViews()

    // Add constraints to subviews
    func configureConstraints()
}

public extension ViewConfigurable {
    func configure() {
        configureViews()
        configureConstraints()
    }
}
