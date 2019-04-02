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
    if let discoverVC = DiscoverySimpleViewController.instantiate() {
      discoverVC.tabBarItem = UITabBarItem(title: "Discovery", image: UIImage(named: "tab-icon-discovery"), selectedImage: nil)
      mainTabVC.addChild(discoverVC)
    }
    
    //      Matches
    if let friendsTabVC = FriendsTabViewController.instantiate(), let selectedImage = R.image.tabIconFriendsSelected() {
      friendsTabVC.tabBarItem = UITabBarItem(title: "Friends",
                                             image: selectedImage.imageWith(newSize: CGSize(width: 30, height: 30))
                                              .withRenderingMode(.alwaysOriginal),
                                             selectedImage: selectedImage.imageWith(newSize: CGSize(width: 30, height: 30))
                                              .withRenderingMode(.alwaysOriginal))
      
      mainTabVC.addChild(friendsTabVC)
    }
    
    //      Profiles
    if let meTabVC = MeTabViewController.instantiate(), let selectedImage = R.image.tabIconMeSelected() {
      meTabVC.tabBarItem =  UITabBarItem(title: "Me",
                                         image: selectedImage.imageWith(newSize: CGSize(width: 30, height: 30))
                                          .withRenderingMode(.alwaysOriginal),
                                         selectedImage: selectedImage.imageWith(newSize: CGSize(width: 30, height: 30))
                                          .withRenderingMode(.alwaysOriginal))
      mainTabVC.addChild(meTabVC)
    }
    
    ////      Matches
    //        if let matchesVC = MatchesMainViewController.instantiate() {
    //            matchesVC.tabBarItem = UITabBarItem(title: "Matches", image: UIImage(named: "tab-icon-matches"), selectedImage: nil)
    //            mainTabVC.addChild(matchesVC)
    //        }
    //
    ////      Profiles
    //        if let profilesVC = ProfilesMainViewController.instantiate() {
    //            profilesVC.tabBarItem =  UITabBarItem(title: "Profiles", image: UIImage(named: "tab-icon-profiles"), selectedImage: nil)
    //            mainTabVC.addChild(profilesVC)
    //        }
    
    ////      Settings
    //        if let settingsVC = SettingsMainViewController.instantiate() {
    //            settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "tab-icon-settings"), selectedImage: nil)
    //            mainTabVC.addChild(settingsVC)
    //        }
    
    return mainTabVC
  }
  
}

// MARK: - Life Cycle
extension MainTabBarViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
}
