//
//  HapticFeedbackGenerator.swift
//  Pear
//
//  Created by Avery Lamp on 2/10/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class HapticFeedbackGenerator {

    class func generateHapticFeedbackImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let feedbackGenerator = UIImpactFeedbackGenerator.init(style: style)
        feedbackGenerator.impactOccurred()
    }

    class func generateHapticFeedbackNotification(style: UINotificationFeedbackGenerator.FeedbackType) {
        let feedbackGenerator = UINotificationFeedbackGenerator.init()
        feedbackGenerator.notificationOccurred(style)
    }

}
