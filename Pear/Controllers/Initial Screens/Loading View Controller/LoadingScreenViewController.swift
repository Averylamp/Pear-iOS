//
//  LoadingScreenViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/3/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebasePerformance
import CodableFirebase
import CoreLocation

class LoadingScreenViewController: UIViewController {
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> LoadingScreenViewController? {
    let storyboard = UIStoryboard(name: String(describing: LoadingScreenViewController.self), bundle: nil)
    guard let loadingScreenVC = storyboard.instantiateInitialViewController() as? LoadingScreenViewController else { return nil }
    
    return loadingScreenVC
  }
  
}

// MARK: - Life Cycle
extension LoadingScreenViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.redirectToCorrectScreen()
  }
  
  func redirectToCorrectScreen() {
    DataStore.shared.reloadRemoteConfig { (_) in
      DataStore.shared.getVersionNumber(versionSufficientCompletion: { (versionIsSufficient) in
        if !versionIsSufficient && DataStore.shared.remoteConfig.configValue(forKey: "version_blocking_enabled").boolValue {
          self.continueToVersionBlockScreen()
        } else {
          DataStore.shared.refreshPearUser(completion: { (pearUser) in
            if pearUser != nil {
              print("pear user refreshed")
              DataStore.shared.getNotificationAuthorizationStatus { status in
                if status == .notDetermined {
                  // user exists but notification auth status undetermined (likely reinstalled the app?), so prompt again
                  if let allowNotificationsVC = AllowNotificationsViewController.instantiate() {
                    DispatchQueue.main.async {
                      self.navigationController?.pushViewController(allowNotificationsVC, animated: true)
                    }
                  } else {
                    print("Failed to create Allow Notifications VC")
                    self.continueToMainScreen()
                  }
                } else {
                  let locationAuthStatus = CLLocationManager.authorizationStatus()
                  if locationAuthStatus == .authorizedWhenInUse || locationAuthStatus == .authorizedAlways {
                    self.continueToMainScreen()
                  } else {
                    guard let allowLocationVC = AllowLocationViewController.instantiate() else {
                      print("Failed to create Allow Location VC")
                      return
                    }
                    DispatchQueue.main.async {
                      self.navigationController?.pushViewController(allowLocationVC, animated: true)
                    }
                  }
                }
              }
            } else {
              self.continueToLandingScreen()
            }
          })
        }
      })
    }
  }
  
  static func getVersionBlockScreen() -> UIViewController? {
    guard let versionBlockVC = VersionBlockViewController.instantiate() else {
      print("Failed to create Version Block VC")
      return nil
    }
    return versionBlockVC
  }
  
  func continueToVersionBlockScreen() {
    print("Continuing to version block screen")
    DispatchQueue.main.async {
      if let versionBlockVC = LoadingScreenViewController.getVersionBlockScreen() {
        self.navigationController?.setViewControllers([versionBlockVC], animated: true)
      } else {
        print("couldn't create version block VC")
      }
    }
  }
  
  static func getLandingScreen() -> UIViewController? {
    if !DataStore.shared.remoteConfig.configValue(forKey: "pineapple_waitlist_enabled").boolValue {
      guard let landingScreenVC = LandingScreenWaitlistViewController.instantiate() else {
        print("Failed to create Landing Screen VC")
        return nil
      }
      return landingScreenVC
    } else {
      guard let landingScreenVC = UserContactPermissionsViewController.instantiate() else {
        print("Failed to create Landing Screen VC")
        return nil
      }
      return landingScreenVC
    }
  }
  
  func continueToLandingScreen() {
    print("Continuing to Landing Screen")
    DispatchQueue.main.async {
      if let landingVC = LoadingScreenViewController.getLandingScreen() {
        self.navigationController?.setViewControllers([landingVC], animated: true)
      }
    }
  }
  
  static func getMainScreenVC() -> UIViewController? {
    if DataStore.shared.remoteConfig.configValue(forKey: "waitlist_enabled").boolValue {
      guard let waitlistVC = GetStartedWaitlistViewController.instantiate() else {
        print("Failed to create Waitlist VC")
        return nil
      }
      return waitlistVC
    } else if DataStore.shared.remoteConfig.configValue(forKey: "pineapple_waitlist_enabled_all_users").boolValue {
      guard let landingScreenVC = LandingScreenWaitlistViewController.instantiate() else {
        print("Failed to create Landing Screen VC")
        return nil
      }
      return landingScreenVC
    } else {
      guard let mainVC = MainTabBarViewController.instantiate() else {
        print("Failed to create Simple Discovery VC")
        return nil
      }
      return mainVC
    }
  }
  
  static func getWaitlistVC() -> UIViewController? {
    guard let waitlistVC = GetStartedWaitlistViewController.instantiate() else {
      print("Failed to create Landing Screen VC")
      return nil
    }
    return waitlistVC
  }
  
  func continueToMainScreen() {
    print("Continuing to Main Screen")
    DispatchQueue.main.async {
      DataStore.shared.reloadAllUserData()
      if let mainVC = LoadingScreenViewController.getMainScreenVC() {
        self.navigationController?.setViewControllers([mainVC], animated: true)
      }
    }
  }
  
  func testChat() {
    
    PearChatAPI.shared.getAllChatsForUser(user_id: "5c82162afec46c84e924a337") { (result) in
      switch result {
      case .success(let chats):
        print(chats)
      case .failure(let error):
        print(error)
      }
    }
    
  }
  
  func testImageUpload() {
    if let testImage = UIImage(named: "sample-profile-brooke-1") {
      let testUserID = "5c82162afec46c84e924a332"
      PearImageAPI.shared.uploadNewImage(with: testImage, userID: testUserID) { (result) in
        print("Image upload returned")
        switch result {
        case .success( let imageAllSizesRepresentation):
          print("Finished Image Test Successfully")
          print(imageAllSizesRepresentation)
        case .failure(let error):
          print("Failed image api request")
          print(error)
        }
      }
    } else {
      fatalError("Failed to create image for image upload test")
    }
  }
  
  func testCheckUserProfiles() {
    DataStore.shared.refreshEndorsedUsers(completion: nil)
  }
  
  func testUpdateUserSchool() {
    PearUserAPI.shared.updateUserSchool(userID: "5c82162afec46c84e924a332",
                                        schoolName: "MIT",
                                        schoolYear: "2020") { (result) in
                                          switch result {
                                          case .success(let successful):
                                            if successful {
                                              print("Update user school was successful")
                                            } else {
                                              print("Update user school was unsuccessful")
                                            }
                                            
                                          case .failure(let error):
                                            print("Update user failure: \(error)")
                                          }
    }
  }
  
  func testUpdateUserPrefs() {
    PearUserAPI.shared.updateUserPreferences(userID: "5c82162afec46c84e924a332",
                                             genderPrefs: ["female"],
                                             minAge: 18,
                                             maxAge: 25,
                                             locationName: nil) { (result) in
                                              switch result {
                                              case .success(let successful):
                                                if successful {
                                                  print("Update user was successful")
                                                } else {
                                                  print("Update user was unsuccessful")
                                                }
                                                
                                              case .failure(let error):
                                                print("Update user failure: \(error)")
                                              }
                                              
    }
    
  }
  
  func testFetchMatchRequests() {
    DataStore.shared.refreshMatchRequests { (matchRequests) in
      print("Found Match Requests: \(matchRequests.count)")
    }
    
    DataStore.shared.refreshCurrentMatches { (matches) in
      print("Found Current Matches: \(matches.count)")
    }
    
  }
  
  func testCreateMatchRequests() {
    PearMatchesAPI.shared.createMatchRequest(sentByUserID: "5c82162afec46c84e924a336",
                                             sentForUserID: "5c82162afec46c84e924a332",
                                             receivedByUserID: "5c82162afec46c84e924a334",
                                             requestText: nil) { (result) in
                                              switch result {
                                              case .success(let successful):
                                                if successful {
                                                  print("Create Match Request 1 was successful")
                                                } else {
                                                  print("Create Match Request 1 was unsuccessful")
                                                }
                                                
                                              case .failure(let error):
                                                print("Create Match Request 1 failure: \(error)")
                                              }
    }
    
    PearMatchesAPI.shared.createMatchRequest(sentByUserID: "5c82162afec46c84e924a332",
                                             sentForUserID: "5c82162afec46c84e924a332",
                                             receivedByUserID: "5c82162afec46c84e924a339",
                                             requestText: nil) { (result) in
                                              switch result {
                                              case .success(let successful):
                                                if successful {
                                                  print("Create Match Request 2 was successful")
                                                } else {
                                                  print("Create Match Request 2 was unsuccessful")
                                                }
                                                
                                              case .failure(let error):
                                                print("Create Match Request 2 failure: \(error)")
                                              }
    }
  }
  
  func testUserProfileUpdates() {
    PearProfileAPI.shared.editUserProfile(profileDocumentID: "5ca7e1bea4b35e29efff5258",
                                          userID: "5c82162afec46c84e924a337",
                                          updates: ["bio": "Heres a new bio for you"]) { (result) in
                                            switch result {
                                            case .success(let successful):
                                              if successful {
                                                print("Successfully updated user profile")
                                              } else {
                                                print("Failure updating user profile")
                                              }
                                            case .failure(let error):
                                              print("Failure updating user profile: \(error)")
                                            }
    }
    
  }
  
  func testDetachedProfileUpdates() {
    PearProfileAPI.shared.editDetachedProfile(profileDocumentID: "5c82162afec46c84e9241117",
                                              userID: "5c82162afec46c84e924a334",
                                              updates: ["bio": "Heres a new bio for you"]) { (result) in
                                                switch result {
                                                case .success(let successful):
                                                  if successful {
                                                    print("Successfully updated detached user profile")
                                                  } else {
                                                    print("Failure updating detached user profile")
                                                  }
                                                case .failure(let error):
                                                  print("Failure updating detached user profile: \(error)")
                                                }
    }
    
  }
  
}
