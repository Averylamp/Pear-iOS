//
//  HapticFeedbackGenerator.swift
//  Pear
//
//  Created by Avery Lamp on 2/10/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class HapticFeedbackGenerator {
    
    static let shared = HapticFeedbackGenerator()
    
    private init(){
        
    }
    
    func generateHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle){
        let feedbackGenerator = UIImpactFeedbackGenerator.init(style: style)
        feedbackGenerator.impactOccurred()
    }
    
}
