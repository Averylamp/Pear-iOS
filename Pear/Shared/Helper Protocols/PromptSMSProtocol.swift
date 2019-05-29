//
//  PromptSMSProtocol.swift
//  Pear
//
//  Created by Avery Lamp on 5/1/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import MessageUI
import FirebaseAnalytics

protocol PromptSMSProtocol {
  func getMessageComposer(profileData: ProfileCreationData) -> MFMessageComposeViewController?
  func getSMSCanceledVC(profileData: ProfileCreationData) -> UIViewController?
  func createDetachedProfile(profileData: ProfileCreationData, completion: @escaping (Result<PearDetachedProfile, (errorTitle: String, errorMessage: String)?>) -> Void)
}

extension PromptSMSProtocol {
  
  func getSMSCanceledVC(profileData: ProfileCreationData) -> UIViewController? {
    // TODO(@averylamp): Fix
//    guard let smsCancledVC = SMSCanceledViewController.instantiate(profileCreationData: profileData) else {
//      print("Failed to create SMS Cancelled VC")
//      return nil
//    }
    return nil
  }
  
  func getMessageComposer(profileData: ProfileCreationData) -> MFMessageComposeViewController? {
    let phoneNumber = profileData.phoneNumber.filter("0123456789".contains)
    if phoneNumber.count == 10 {      
      if MFMessageComposeViewController.canSendText() {
        let messageVC = MFMessageComposeViewController()
        
        messageVC.recipients = [phoneNumber]
        messageVC.body = "Join me on Pear! 🍐 https://getpear.com/go/refer"
        if let memeImage = R.image.inviteMeme(),
          let pngData = memeImage.pngData() {
          messageVC.addAttachmentData(pngData, typeIdentifier: "public.data", filename: "Image.png")
        }
        return messageVC
      } else {
        return nil
      }
    }
    return nil
  }
  
  func getMessageComposer(phoneNumber: String) -> MFMessageComposeViewController? {
    let filteredNumber = phoneNumber.filter("0123456789".contains)
    if filteredNumber.count == 10 {
      if MFMessageComposeViewController.canSendText() {
        let messageVC = MFMessageComposeViewController()
        messageVC.recipients = [phoneNumber]
        messageVC.body = "Join me on Pear! 🍐 https://getpear.com/go/refer"
        if let memeImage = R.image.inviteMeme(),
          let pngData = memeImage.pngData() {
          messageVC.addAttachmentData(pngData, typeIdentifier: "public.data", filename: "Image.png")
        }
        return messageVC
      } else {
        return nil
      }
    }
    return nil
  }
  
  func createDetachedProfile(profileData: ProfileCreationData, completion: @escaping (Result<PearDetachedProfile, (errorTitle: String, errorMessage: String)?>) -> Void) {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
        completion(.failure((errorTitle: "Please login first", errorMessage: "You must be logged in to create profiles")))
        return
    }
    profileData.updateAuthor(authorID: userID, authorFirstName: DataStore.shared.currentPearUser?.firstName ?? "")
    PearProfileAPI.shared.createNewDetachedProfile(profileCreationData: profileData) { (result) in
      switch result {
      case .success(let detachedProfile):
        Analytics.logEvent("CP_SUCCESS", parameters: nil)
        DataStore.shared.reloadAllUserData()
        completion(.success(detachedProfile))
      case .failure(let error):
        Analytics.logEvent("CP_FAIL", parameters: nil)
        switch error {
        case .graphQLError(let message):
          completion(.failure((errorTitle: "Failed to Create Profile", errorMessage: message)))
        case .userNotLoggedIn:
          completion(.failure((errorTitle: "Please login first", errorMessage: "You must be logged in to create profiles")))
        default:
          completion(.failure((errorTitle: "Oopsie",
                               errorMessage: "Our server made an oopsie woopsie.  Please try again or let us know and we will do our best to fix it ASAP (support@getpear.com)")))
        }
        
      }
    }
  }
  
}
