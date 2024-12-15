//
//  AutoLayoutLabel.swift
//  JoySpring
//
//  Created by Vlad Sys on 16.09.24.
//

import UIKit

public class AutoLayoutLabel: UILabel {
// MARK: - Methods

    override public func layoutSubviews() {
        super.layoutSubviews()

        self.preferredMaxLayoutWidth = self.bounds.width
    }
}
