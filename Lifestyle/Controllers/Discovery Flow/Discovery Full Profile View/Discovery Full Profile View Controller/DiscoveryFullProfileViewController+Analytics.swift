//
//  DiscoveryFullProfileViewController+Analytics.swift
//  Pear
//
//  Created by Avery Lamp on 6/18/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

extension DiscoveryFullProfileViewController {
  
  func slackHelperDetails() -> String {
    let percentProfileSeen = min(100, round((self.maxContentOffset + self.view.frame.height) / self.scrollView.contentSize.height * 100))
    let result = "\nProfile seen: \(percentProfileSeen)%, Scroll Distance: \(round(self.totalScrollDistance / self.scrollView.contentSize.height * 100) / 100)X in \(round((CACurrentMediaTime() - initializationTime) * 100) / 100)s"
    return result
  }
  
}
