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
    print("Max content offset: \(self.maxContentOffset), frameHeight: \(self.view.frame.height), contentHeight: \(self.scrollView.contentSize.height)")
    let percentProfileSeen = min(100, round((self.maxContentOffset + self.view.frame.height) / self.scrollView.contentSize.height * 100))
    let result = " Profile seen: \(percentProfileSeen)%, Scroll Distance: \(round(self.totalScrollDistance / self.scrollView.contentSize.height * 100) / 100)X in \(round((CACurrentMediaTime() - initializationTime) * 100) / 100)s"
    print(result)
    return result
  }
  
}
