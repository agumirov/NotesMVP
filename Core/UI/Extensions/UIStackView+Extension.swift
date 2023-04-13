//
//  UIStackView+Extension.swift
//  TestNotes
//
//  Created by G G on 25.03.2023.
//

import Foundation
import UIKit

extension UIStackView {
    func addArrangedSubviews(views: [UIView]) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }
}
