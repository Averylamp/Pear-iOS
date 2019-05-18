//
//  PermissionsProtocol+UIViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol PermissionsFlowProtocol: UIViewController {
  // Nested Functions
  func continueToEmailOrNext()
  func continueToLocationOrNext()
  func continueToNotificationOrNext()
  func continueToOnboardingOrMain()
  // Redirect functions
  func continueToVersionBlockingScreen()
  func continueToLandingPage()
  func continueToUpdateEmail()
  func continueToAllowNotifications()
  func continueToAllowLocation()
  func continueToMainVC()
  func continueToOnboarding()
  func continueToLocationBlockedPage()
}

// MARK: - Permissions Flow
extension PermissionsFlowProtocol {
  
  func continueToEmailOrNext() {
    guard let user = DataStore.shared.currentPearUser else {
      print("Something is very wrong")
      #if DEVMODE
      fatalError("Should not try to continue to email without having logged in")
      #endif
      return
    }
    if user.email == nil {
      self.continueToUpdateEmail()
    } else {
      print("Skipping Update Email Page")
      self.continueToLocationOrNext()
    }
  }
  
  func continueToLocationOrNext() {
    let locationStatus = CLLocationManager.authorizationStatus()
    if locationStatus != .authorizedWhenInUse && locationStatus != .authorizedAlways {
      self.continueToAllowLocation()
      return
    }
    DataStore.shared.withinBostonArea { (withinBoston) in
      if let withinBoston = withinBoston {
        if withinBoston  || DataStore.shared.fetchFlagFromDefaults(flag: .hasBeenInBostonArea) {
          DataStore.shared.setFlagToDefaults(value: true, flag: .hasBeenInBostonArea)
          print("Skipping Allow Locations Page")
          self.continueToNotificationOrNext()
        } else {
          print("Found Location Blocking Condition")
          self.continueToLocationBlockedPage()
        }
        return
      } else {
        self.continueToAllowLocation()
      }
    }

  }
  
  func continueToNotificationOrNext() {
    DataStore.shared.getNotificationAuthorizationStatus { (status) in
      if status != .authorized {
        self.continueToAllowNotifications()
        return
      } else {
        print("Skipping Allow Notifications Page")
        self.continueToOnboardingOrMain()
        return
      }
    }
  }
  
  func continueToOnboardingOrMain() {
    DispatchQueue.main.async {
      if DataStore.shared.fetchFlagFromDefaults(flag: .hasCompletedOnboarding) {
        print("Continuing to Main VC")
        self.continueToMainVC()
      } else {
        print("Continuing to Onboarding")
        self.continueToOnboarding()
      }
    }
  }
  
}

// MARK: - Continue To VCs
extension PermissionsFlowProtocol {
  
  func continueToVersionBlockingScreen() {
    DispatchQueue.main.async {
      guard let versionBlockVC = VersionBlockViewController.instantiate() else {
        print("Failed to create Version Block VC")
        return
      }
      self.navigationController?.setViewControllers([versionBlockVC], animated: true)
    }
  }
  
  func continueToLandingPage() {
    DispatchQueue.main.async {
      guard let landingPageVC = LandingScreenViewController.instantiate() else {
        print("Failed to create Landing Screen VC")
        return
      }
      self.navigationController?.setViewControllers([landingPageVC], animated: true)
    }
  }
  
  func continueToUpdateEmail() {
    DispatchQueue.main.async {
      guard let userEmailVC = UserEmailInfoViewController.instantiate() else {
        print("Failed to create user email VC")
        return
      }
      self.navigationController?.setViewControllers([userEmailVC], animated: true)
    }
  }
  
  func continueToAllowNotifications() {
    DispatchQueue.main.async {
      guard let allowNotificationsVC = AllowNotificationsViewController.instantiate() else {
        print("Failed to create allow Notifications VC")
        return
      }
      self.navigationController?.setViewControllers([allowNotificationsVC], animated: true)
    }
  }
  
  func continueToAllowLocation() {
    DispatchQueue.main.async {
      guard let allowLocationVC = AllowLocationViewController.instantiate() else {
        print("Failed to create allow Location VC")
        return
      }
      self.navigationController?.setViewControllers([allowLocationVC], animated: true)
    }
  }
  
  func continueToMainVC() {
    DispatchQueue.main.async {
      guard let mainVC = MainTabBarViewController.instantiate() else {
        print("Failed to create main VC")
        return
      }
      self.navigationController?.setViewControllers([mainVC], animated: true)
    }
  }
  
  func continueToOnboarding() {
    DispatchQueue.main.async {
//      guard let initialOnboardingVC = OnboardingExplainationPage1ViewController.instantiate() else {
//        print("Unable to create initial onboarding VC")
//        return
//      }
      guard let initialOnboardingVC = OnboardingBasicInfoViewController.instantiate() else {
        print("Unable to create initial onboarding VC")
        return
      }
      self.navigationController?.setViewControllers([initialOnboardingVC], animated: true)
    }
  }
  
  func continueToLocationBlockedPage() {
    DispatchQueue.main.async {
      guard let locationBlockedVC = LocationBlockedViewController.instantiate() else {
        print("Unable to create initial onboarding VC")
        return
      }
      self.navigationController?.setViewControllers([locationBlockedVC], animated: true)
    }
  }
  
}
