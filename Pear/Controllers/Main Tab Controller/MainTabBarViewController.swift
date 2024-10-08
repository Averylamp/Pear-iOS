//
//  MainTabBarViewController.swift
//  SubtleAsianMatches
//
//  Created by Avery on 1/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import CoreLocation

extension Notification.Name {
  static let updateAppIconNumber = Notification.Name("updateAppIcontNumber")
  static let goToFriendsTab = Notification.Name("goToFriendsTab")
  static let goToEditProfile = Notification.Name("goToEditPersonalProfile")
}

enum NotificationUserInfoKey: String {
  case friendUserID
}

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
      likesTabVC.tabBarItem.badgeColor = UIColor(red: 1, green: 0.81, blue: 0.32, alpha: 1)
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
      chatTabVC.tabBarItem.badgeColor = UIColor(red: 1, green: 0.81, blue: 0.32, alpha: 1)
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
    self.setup()
    self.stylize()
  }
  
  /// Setup should only be called once
  func setup() {
    self.delegate = self
    self.addNotificationSubscriptions()
  }
  
  func addNotificationSubscriptions() {
    NotificationCenter
      .default
      .addObserver(self,
                                           selector: #selector(MainTabBarViewController.updateAppIconNumber),
                                           name: .updateAppIconNumber,
                                           object: nil)
    NotificationCenter
      .default
    .addObserver(self,
                 selector: #selector(MainTabBarViewController.goToFriendsTab(notification:)),
                 name: .goToFriendsTab,
                 object: nil)
    NotificationCenter
      .default
      .addObserver(self,
                   selector: #selector(MainTabBarViewController.goToEditProfile(notification:)),
                   name: .goToEditProfile,
                   object: nil)

  }
  
  /// Stylize can be called more than once
  func stylize() {
    self.tabBar.barTintColor = UIColor.white
    self.tabBar.layer.borderWidth = 0
    self.tabBar.layer.shadowOpacity = 1
    self.tabBar.layer.shadowRadius = 8
    self.tabBar.layer.shadowColor = UIColor(white: 0.90, alpha: 0.5).cgColor
    self.tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
    self.tabBar.layer.borderColor = UIColor.white.cgColor
    self.tabBar.barStyle = .black
  }
  
}

// MARK: - Shared Notification Functions
extension MainTabBarViewController {

  @objc func updateAppIconNumber() {
    var appIconNumber = 0
    appIconNumber += DataStore.shared.matchRequests.count
    DataStore.shared.currentMatches.compactMap({$0.chat}).forEach({
      if let lastMessageTimestamp = $0.messages.last?.timestamp,
        $0.lastOpenedDate.compare(lastMessageTimestamp) == .orderedAscending {
        appIconNumber += 1
      }
    })
    
    DispatchQueue.main.async {
      UIApplication.shared.applicationIconBadgeNumber = appIconNumber
    }
  }
  
}

// MARK: - Redirect Notificaions
extension MainTabBarViewController {
  
  @objc func goToEditProfile(notification: NSNotification) {
    DispatchQueue.main.async {
      self.selectedIndex = 3
    }
  }
  
  @objc func goToFriendsTab(notification: NSNotification) {
    DispatchQueue.main.async {
      self.selectedIndex = 3      
    }
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
