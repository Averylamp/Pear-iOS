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

class LoadingScreenViewController: OnboardingViewController {
  
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
          SlackHelper.shared.addEvent(text: "This user is version blocked", color: UIColor.red)
          self.continueToVersionBlockingScreen()
        } else {
          DataStore.shared.refreshPearUser(completion: { (pearUser) in
            if let pearUser = pearUser {
              DataStore.shared.currentPearUser = pearUser
              self.continueToLocationOrNext()
            } else {
              SlackHelper.shared.addEvent(text: "Showing user landing page", color: UIColor.yellow)
              self.continueToLandingPage()
            }
          })
        }
      })
    }
  }
  
  static func getMainScreenVC() -> UIViewController? {
    guard let mainVC = MainTabBarViewController.instantiate() else {
      print("Failed to create Simple Discovery VC")
      return nil
    }
    return mainVC
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
                                             locationName: nil,
                                             isSeeking: nil) { (result) in
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
  
  func testEventCode() {
    PearUserAPI.shared.addEventCode(code: "TESTCODE") { (result) in
      switch result {
      case .success(let successful):
        if successful {
          print("Adding event code successful")
        } else {
          print("Adding event code unsuccessful")
        }
      case .failure(let error):
        print("Failure adding event code: \(error)")
      }
    }
  }
  
  func testGetEvent() {
    PearEventAPI.shared.getEvent(eventID: "5cec470fcbfa9d14ed04c8e5") { (result) in
      switch result {
      case .success(let successful):
        print(successful)
      case .failure(let error):
        print("Failure getting event: \(error)")
      }
    }
  }
//  
//  func testUserProfileUpdates() {
//    PearProfileAPI.shared.editUserProfile(profileDocumentID: "5ca7e1bea4b35e29efff5258",
//                                          userID: "5c82162afec46c84e924a337",
//                                          updates: ["bio": "Heres a new bio for you"]) { (result) in
//                                            switch result {
//                                            case .success(let successful):
//                                              if successful {
//                                                print("Successfully updated user profile")
//                                              } else {
//                                                print("Failure updating user profile")
//                                              }
//                                            case .failure(let error):
//                                              print("Failure updating user profile: \(error)")
//                                            }
//    }
//    
//  }
//  
//  func testDetachedProfileUpdates() {
//    PearProfileAPI.shared.editDetachedProfile(profileDocumentID: "5c82162afec46c84e9241117",
//                                              userID: "5c82162afec46c84e924a334",
//                                              updates: ["bio": "Heres a new bio for you"]) { (result) in
//                                                switch result {
//                                                case .success(let successful):
//                                                  if successful {
//                                                    print("Successfully updated detached user profile")
//                                                  } else {
//                                                    print("Failure updating detached user profile")
//                                                  }
//                                                case .failure(let error):
//                                                  print("Failure updating detached user profile: \(error)")
//                                                }
//    }
//    
//  }
  
  func testGetAllQuestions() {
    PearContentAPI.shared.getQuestions { (result) in
      switch result {
      case .success(let questions):
        print("\(questions.count) Questions Found")
      case .failure(let error):
        print("Error retrieving questions:\(error)")
      }
    }
  }
  
}
