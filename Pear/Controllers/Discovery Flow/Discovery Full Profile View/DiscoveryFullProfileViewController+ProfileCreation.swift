//
//  DiscoveryFullProfileViewController+ProfileCreation.swift
//  Pear
//
//  Created by Avery Lamp on 5/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI

// MARK: - Profile Creation Prompts
extension DiscoveryFullProfileViewController {
  
  func promptEndorsedProfileCreation() {
    let alertController = UIAlertController(title: "Match a Friend!",
                                            message: "Make a profile for a friend to pair them with \(self.fullProfileData.firstName!) or others.",
      preferredStyle: .alert)
    let createProfile = UIAlertAction(title: "Continue", style: .default) { (_) in
      DispatchQueue.main.async {
        self.promptContactsPicker()
      }
    }
    
    let maybeLater = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(createProfile)
    alertController.addAction(maybeLater)
    self.present(alertController, animated: true, completion: nil)
  }
  
  func promptProfileRequest() {
    let alertController = UIAlertController(title: "Match with yourself?",
                                            message: "To match this person with yourself, ask a friend to make you a profile first!",
                                            preferredStyle: .alert)
    let createProfile = UIAlertAction(title: "Ask a friend", style: .default) { (_) in
      DispatchQueue.main.async {
        guard let requestProfileVC = RequestProfileViewController.instantiate() else {
          print("Failed to create get started friend profile vc")
          return
        }
        self.present(requestProfileVC, animated: true, completion: nil)
      }
    }
    
    let maybeLater = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(createProfile)
    alertController.addAction(maybeLater)
    self.present(alertController, animated: true, completion: nil)
  }
  
}

// MARK: ProfileCreationProtocol
extension DiscoveryFullProfileViewController: ProfileCreationProtocol, CNContactPickerDelegate {
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    self.didSelectContact(contact: contact)
  }
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
    self.didSelectContactProperty(contactProperty: contactProperty)
  }
  
  func receivedProfileCreationData(creationData: ProfileCreationData) {
    DispatchQueue.main.async {
      // TODO(@averylamp) : Profile creation
//      guard let vibesVC = ProfileInputVibeViewController.instantiate(profileCreationData: creationData) else {
//        print("Failed to create Vibes VC")
//        return
//      }
//      self.navigationController?.pushViewController(vibesVC, animated: true)
    }
  }
  
  func recievedProfileCreationError(title: String, message: String?) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true)
    }
  }
  
  func promptContactsPicker() {
    let cnPicker = self.getContactsPicker()
    cnPicker.delegate = self
    self.present(cnPicker, animated: true, completion: nil)
  }
  
}
