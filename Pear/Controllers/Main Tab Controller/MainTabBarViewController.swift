//
//  MainTabBarViewController.swift
//  SubtleAsianMatches
//
//  Created by Avery on 1/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import CoreLocation

class MainTabBarViewController: UITabBarController {
  
  static let iconSize: CGFloat = 40
  
  class func instantiate() -> MainTabBarViewController? {
    let storyboard = UIStoryboard(name: String(describing: MainTabBarViewController.self), bundle: nil)
    guard let mainTabVC = storyboard.instantiateInitialViewController() as? MainTabBarViewController else { return nil }
    //      Discovery
    if let discoverVC = DiscoveryDecisionViewController.instantiate(),
      let regularImage = R.image.tabIconDiscovery(),
      let selectedImage = R.image.tabIconDiscoverySelected() {
      discoverVC.tabBarItem = UITabBarItem(title: nil,
                                           image: regularImage.imageWith(newSize:
                                            CGSize(width: MainTabBarViewController.iconSize, height: MainTabBarViewController.iconSize))
                                            .withRenderingMode(.alwaysOriginal),
                                           selectedImage: selectedImage.imageWith(newSize:
                                            CGSize(width: MainTabBarViewController.iconSize, height: MainTabBarViewController.iconSize))
                                            .withRenderingMode(.alwaysOriginal))
      discoverVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
      mainTabVC.addChild(discoverVC)
    }
    
    //      Chat
    if let chatTabVC = ChatMainViewController.instantiate(),
      let regularImage = R.image.tabIconChat(),
      let selectedImage = R.image.tabIconChatSelected() {
      chatTabVC.tabBarItem = UITabBarItem(title: nil,
                                             image: regularImage.imageWith(newSize:
                                              CGSize(width: MainTabBarViewController.iconSize, height: MainTabBarViewController.iconSize))
                                              .withRenderingMode(.alwaysOriginal),
                                             selectedImage: selectedImage.imageWith(newSize:
                                              CGSize(width: MainTabBarViewController.iconSize, height: MainTabBarViewController.iconSize))
                                              .withRenderingMode(.alwaysOriginal))
      chatTabVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
      mainTabVC.addChild(chatTabVC)
    }
    
    //      You
    if let meTabVC = MeTabMainViewController.instantiate(),
      let regularImage = R.image.tabIconYou(),
      let selectedImage = R.image.tabIconYouSelected() {
      meTabVC.tabBarItem =  UITabBarItem(title: nil,
                                         image: regularImage.imageWith(newSize:
                                          CGSize(width: MainTabBarViewController.iconSize, height: MainTabBarViewController.iconSize))
                                          .withRenderingMode(.alwaysOriginal),
                                         selectedImage: selectedImage.imageWith(newSize:
                                          CGSize(width: MainTabBarViewController.iconSize, height: MainTabBarViewController.iconSize))
                                          .withRenderingMode(.alwaysOriginal))
      meTabVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
      mainTabVC.addChild(meTabVC)
    }
    
    return mainTabVC
  }
  
}

// MARK: - Life Cycle
extension MainTabBarViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
    self.stylize()
  }
  
  func stylize() {
    self.tabBar.barTintColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)
  }
  
}

extension MainTabBarViewController: UITabBarControllerDelegate {
  
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if let index = tabBarController.viewControllers?.firstIndex(of: viewController),
      index == 0 {
      // NotificationCenter.default.post(name: .refreshDiscoveryFeed, object: nil)
    }
    if let index = tabBarController.viewControllers?.firstIndex(of: viewController),
      index == 1 {
      DataStore.shared.refreshCurrentMatches(matchRequestsFound: nil)
      DataStore.shared.refreshMatchRequests(matchRequestsFound: nil)
    }
    if let index = tabBarController.viewControllers?.firstIndex(of: viewController),
      index > 0 {
      self.setTabBarVisible(visible: true, duration: 0.3, animated: true)
    }
    if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
      switch index {
      case 0:
        SlackHelper.shared.addEvent(text: "User switched to Discovery", color: UIColor.orange)
      case 1:
        SlackHelper.shared.addEvent(text: "User switched to Chat", color: UIColor.orange)
      case 2:
        SlackHelper.shared.addEvent(text: "User switched to Profile", color: UIColor.orange)
      default:
        break        
      }
    }
  }
  
}
