//
//  ProgressBarProtocol.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

protocol ProgressBarProtocol: UIViewController {
  var progressWidthConstraint: NSLayoutConstraint { get }
  func setPreviousPageProgress()
  func setCurrentPageProgress(animated: Bool)
  var progressBarCurrentPage: Int { get }
  var progressBarTotalPages: Int { get }
  var progressBarAnimationTime: Double { get }
  var progressBarAnimationDelayTime: Double { get }
}

extension ProgressBarProtocol {
  
  var progressBarAnimationTime: Double {
    return 0.4
  }
  var progressBarAnimationDelayTime: Double {
    return 0.4
  }
  
  func setPreviousPageProgress() {
    self.view.layoutIfNeeded()
    progressWidthConstraint.constant = CGFloat(self.progressBarCurrentPage - 1) / CGFloat(self.progressBarTotalPages) * self.view.frame.width
    self.view.layoutIfNeeded()
  }
  
  func setCurrentPageProgress(animated: Bool) {
    progressWidthConstraint.constant = CGFloat(self.progressBarCurrentPage) / CGFloat(self.progressBarTotalPages) * self.view.frame.width
    if animated {
      UIView.animate(withDuration: self.progressBarAnimationTime,
                     delay: self.progressBarAnimationDelayTime,
                     options: .curveEaseOut, animations: {
                      self.view.layoutIfNeeded()
      }, completion: nil)
    } else {
      self.view.layoutIfNeeded()
    }
  }
}
