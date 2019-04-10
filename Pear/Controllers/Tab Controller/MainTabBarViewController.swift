//
//  MainTabBarViewController.swift
//  SubtleAsianMatches
//
//  Created by Avery on 1/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
  
  class func instantiate() -> MainTabBarViewController? {
    let storyboard = UIStoryboard(name: String(describing: MainTabBarViewController.self), bundle: nil)
    guard let mainTabVC = storyboard.instantiateInitialViewController() as? MainTabBarViewController else { return nil }
    
    //      Discovery
    if let discoverVC = DiscoverySimpleViewController.instantiate(),
      let regularImage = R.image.tabIconDiscovery(),
      let selectedImage = R.image.tabIconDiscoverySelected() {
      discoverVC.tabBarItem = UITabBarItem(title: "Discover",
                                             image: regularImage.imageWith(newSize: CGSize(width: 30, height: 30))
                                              .withRenderingMode(.alwaysOriginal),
                                             selectedImage: selectedImage.imageWith(newSize: CGSize(width: 30, height: 30))
                                              .withRenderingMode(.alwaysOriginal))
      mainTabVC.addChild(discoverVC)
    }

    //      Chat
    if let chatTabVC = ChatMainViewController.instantiate(),
      let regularImage = R.image.tabIconChat(),
      let selectedImage = R.image.tabIconChatSelected() {
      chatTabVC.tabBarItem = UITabBarItem(title: "Chat",
                                             image: regularImage.imageWith(newSize: CGSize(width: 30, height: 30))
                                              .withRenderingMode(.alwaysOriginal),
                                             selectedImage: selectedImage.imageWith(newSize: CGSize(width: 30, height: 30))
                                              .withRenderingMode(.alwaysOriginal))
      
      mainTabVC.addChild(chatTabVC)
    }
    
    //      Friendos
    if let friendsTabVC = FriendsTabViewController.instantiate(),
      let regularImage = R.image.tabIconFriends(),
      let selectedImage = R.image.tabIconFriendsSelected() {
      friendsTabVC.tabBarItem = UITabBarItem(title: "Friends",
                                             image: regularImage.imageWith(newSize: CGSize(width: 30, height: 30))
                                              .withRenderingMode(.alwaysOriginal),
                                             selectedImage: selectedImage.imageWith(newSize: CGSize(width: 30, height: 30))
                                              .withRenderingMode(.alwaysOriginal))
      
      mainTabVC.addChild(friendsTabVC)
    }
    
    //      You
    if let meTabVC = MeTabViewController.instantiate(),
      let regularImage = R.image.tabIconYou(),
      let selectedImage = R.image.tabIconYouSelected() {
      meTabVC.tabBarItem =  UITabBarItem(title: "Me",
                                         image: regularImage.imageWith(newSize: CGSize(width: 30, height: 30))
                                          .withRenderingMode(.alwaysOriginal),
                                         selectedImage: selectedImage.imageWith(newSize: CGSize(width: 30, height: 30))
                                          .withRenderingMode(.alwaysOriginal))
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
  }
  
}

extension MainTabBarViewController: UITabBarControllerDelegate {
  
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    switch tabBarController.selectedIndex {
    case 0:
      HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    case 1:
      HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .medium)
    case 2:
      HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .heavy)
    default:
      HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
      
    }
    
  }
  
}
