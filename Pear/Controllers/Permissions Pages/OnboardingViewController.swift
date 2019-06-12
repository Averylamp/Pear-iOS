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
import UserNotifications

class OnboardingViewController: UIViewController {

  var firstLocationCompletion: (() -> Void)?

  @objc func didReceiveNewLocationAuthorizationStatus(status: CLAuthorizationStatus) {
    
  }
  
  @objc func didReceiveNewNotificationAuthorizationStatus(status: UNAuthorizationStatus) {
    
  }
}

// MARK: - Permissions Flow
extension OnboardingViewController {
  
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
      self.continueToEventCodeOrNext()
    }
  }
  
  func continueToEventCodeOrNext() {
    let now = Date()
    let end = Date(timeIntervalSince1970: TimeInterval(1559620800.0))
    if now < end {
      self.continueToEventCode()
    } else {
      self.continueToLocationOrNext()
    }
  }
  
  func continueToLocationOrNext() {
    let locationStatus = CLLocationManager.authorizationStatus()
    if locationStatus != .authorizedWhenInUse && locationStatus != .authorizedAlways {
      SlackHelper.shared.addEvent(text: "Showing user location permissions page", color: UIColor.yellow)
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
          SlackHelper.shared.addEvent(text: "Showing user location blocked", color: UIColor.red)
          self.continueToLocationBlockedPage()
        }
        return
      } else {
        SlackHelper.shared.addEvent(text: "Showing user location permissions page", color: UIColor.yellow)
        self.continueToAllowLocation()
      }
    }

  }
  
  func continueToNotificationOrNext() {
    DataStore.shared.getNotificationAuthorizationStatus { (status) in
      if status != .authorized {
        SlackHelper.shared.addEvent(text: "Showing user notifications permissions page", color: UIColor.yellow)
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
        SlackHelper.shared.addEvent(text: "Showing user Main Tab Controller", color: UIColor.yellow)
        self.continueToMainVC()
      } else {
        print("Continuing to Onboarding")
        SlackHelper.shared.addEvent(text: "Showing user Onboarding Flow", color: UIColor.yellow)
        self.continueToOnboarding()
      }
    }
  }
  
}

// MARK: - Continue To VCs
extension OnboardingViewController {
  
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
  
  private func continueToUpdateEmail() {
    DispatchQueue.main.async {
      guard let userEmailVC = UserEmailInfoViewController.instantiate() else {
        print("Failed to create user email VC")
        return
      }
      self.navigationController?.setViewControllers([userEmailVC], animated: true)
    }
  }
  
  private func continueToEventCode() {
    DispatchQueue.main.async {
      guard let joinEventVC = JoinEventViewController.instantiate(isInOnboarding: true) else {
        print("Failed to create Join Event VC")
        return
      }
      self.navigationController?.setViewControllers([joinEventVC], animated: true)
    }
  }
  
  private func continueToAllowLocation() {
    DispatchQueue.main.async {
      guard let allowLocationVC = AllowLocationViewController.instantiate() else {
        print("Failed to create allow Location VC")
        return
      }
      self.navigationController?.setViewControllers([allowLocationVC], animated: true)
    }
  }
  
  private func continueToAllowNotifications() {
    DispatchQueue.main.async {
      guard let allowNotificationsVC = AllowNotificationsViewController.instantiate() else {
        print("Failed to create allow Notifications VC")
        return
      }
      self.navigationController?.setViewControllers([allowNotificationsVC], animated: true)
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
  
  private func continueToOnboarding() {
    DispatchQueue.main.async {
      guard let initialOnboardingVC = OnboardingExplainationPage1ViewController.instantiate() else {
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

// MARK: - FetchFirstLocation
extension OnboardingViewController {
  
  func fetchFirstLocation(completion: @escaping () -> Void) {
    if DataStore.shared.locationManager.location?.coordinate != nil {
      completion()
      return
    } else {
      self.firstLocationCompletion = completion
      DataStore.shared.locationDelegate = self
      DataStore.shared.firstLocationReceived = false
      DataStore.shared.startReceivingLocationChanges()
    }
  }
  
}

// MARK: - Data Store Location Delegate
extension OnboardingViewController: DataStoreLocationDelegate {
  
  func firstLocationReceived(location: CLLocationCoordinate2D) {
    if let locationCompletion = self.firstLocationCompletion {
      locationCompletion()
      self.firstLocationCompletion = nil
    }
  }
  
  @objc func authorizationStatusChanged(status: CLAuthorizationStatus) {
    print("authorization status changed; handling new status \(status)")
    self.didReceiveNewLocationAuthorizationStatus(status: status)
  }
  
}

// MARK: - Notificaiton Status Changed
extension OnboardingViewController {
  
}
