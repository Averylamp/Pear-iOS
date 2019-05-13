//
//  UITabBarController+Helpers.swift
//  Pear
//
//  Created by Avery Lamp on 5/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

extension UITabBarController {
  
  func snapTabBar() {
    
  }
  
  func offsetTabBar(yOffset: CGFloat) {
    let frame = self.tabBar.frame
    let height = frame.size.height
    let offsetY = yOffset
    print(offsetY)
    print(self.tabBar.frame.origin.y)
    print(self.view.safeAreaInsets.bottom)
    if offsetY + self.tabBar.frame.origin.y >= UIWindow().screen.bounds.height ||
      offsetY + self.tabBar.frame.origin.y <= UIWindow().screen.bounds.height - self.view.safeAreaInsets.bottom - height {
      return
    }
    self.tabBar.frame.offsetBy(dx: 0, dy: offsetY)
    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + offsetY)
    self.view.setNeedsDisplay()
    self.view.layoutIfNeeded()
  }
  
  func setTabBarVisible(visible: Bool, duration: TimeInterval, animated: Bool) {
    if tabBarIsVisible() == visible { return }
    let frame = self.tabBar.frame
    let height = frame.size.height
    let offsetY = (visible ? -height : height)
    
    // animation
    UIViewPropertyAnimator(duration: duration, curve: .linear) {
      self.tabBar.frame.offsetBy(dx: 0, dy: offsetY)
      self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + offsetY)
      self.view.setNeedsDisplay()
      self.view.layoutIfNeeded()
      }.startAnimation()
  }
  
  func tabBarIsVisible() -> Bool {
    return self.tabBar.frame.origin.y < UIScreen.main.bounds.height
  }
  
}
