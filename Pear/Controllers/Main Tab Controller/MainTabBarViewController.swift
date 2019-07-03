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
      print(discoverVC.view.frame)
    }
    
    //      Likes
    if let likesTabVC = MainLikesViewController.instantiate(),
      let regularImage = R.image.tabIconLikes(),
      let selectedImage = R.image.tabIconLikesSelected() {
      likesTabVC.tabBarItem = UITabBarItem(title: nil,
                                        image: regularImage.imageWith(newSize:
                                          CGSize(width: MainTabBarViewController.iconSize, height: MainTabBarViewController.iconSize))
                                          .withRenderingMode(.alwaysOriginal),
                                        selectedImage: selectedImage.imageWith(newSize:
                                          CGSize(width: MainTabBarViewController.iconSize, height: MainTabBarViewController.iconSize))
                                          .withRenderingMode(.alwaysOriginal))
      likesTabVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
      mainTabVC.addChild(likesTabVC)
      // Delays preloading of VC
      mainTabVC.delay(delay: 0.5) {
        DispatchQueue.main.async {
          print(likesTabVC.view.frame)
        }
      }
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
      // Delays preloading of VC
      mainTabVC.delay(delay: 0.5) {
        DispatchQueue.main.async {
          print(chatTabVC.view.frame)
        }
      }
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
      // Delays preloading of VC
      mainTabVC.delay(delay: 0.5) {
        DispatchQueue.main.async {
          print(meTabVC.view.frame)
        }
      }
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
    self.tabBar.barTintColor = UIColor.white
    self.tabBar.layer.borderWidth = 0
    self.tabBar.layer.shadowOpacity = 1
    self.tabBar.layer.shadowRadius = 8
    self.tabBar.layer.shadowColor = UIColor(white: 0.90, alpha: 0.5).cgColor
    self.tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
    self.tabBar.layer.borderColor = UIColor.white.cgColor
    self.tabBar.barStyle = .black
//    self.tabBar.clipsToBounds = true
//    self.tabBar.barStyle = .blackTranslucent
//    self.tabBar.isTranslucent = true
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
      index == 2 {
      DataStore.shared.refreshMatchRequests(matchRequestsFound: nil)
    }
    if let index = tabBarController.viewControllers?.firstIndex(of: viewController),
      index > 0 {
      self.setTabBarVisible(visible: true, duration: 0.3, animated: true)
    }
    if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
      switch index {
      case 0:
        SlackHelper.shared.addEvent(text: "User switched to Discovery Tab", color: UIColor.orange)
      case 1:
        SlackHelper.shared.addEvent(text: "User switched to Likes Tab", color: UIColor.orange)
      case 2:
        SlackHelper.shared.addEvent(text: "User switched to Chat Tab", color: UIColor.orange)
      case 3:
        SlackHelper.shared.addEvent(text: "User switched to Profile Tab", color: UIColor.orange)
      default:
        break        
      }
    }
  }
  
}
