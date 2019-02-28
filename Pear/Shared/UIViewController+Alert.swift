//
//  UIViewController+Alert.swift
//  SubtleAsianMatches
//
//  Created by Kelvin Lau on 2018-12-26.
//  Copyright © 2018 sam. All rights reserved.
//

import UIKit

extension UIViewController {

    /// Presents a `UIAlertController` popup with `.alert` style, with a default "Ok" button that dismisses the popup.
    ///
    /// - Parameters:
    ///   - title: Title for the alert.
    ///   - message: Message for the alert.
    func alert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
