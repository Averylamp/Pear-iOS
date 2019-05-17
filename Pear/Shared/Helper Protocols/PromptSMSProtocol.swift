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
    guard let smsCancledVC = SMSCanceledViewController.instantiate(profileCreationData: profileData) else {
      print("Failed to create SMS Cancelled VC")
      return nil
    }
    return smsCancledVC
  }
  
  func getMessageComposer(profileData: ProfileCreationData) -> MFMessageComposeViewController? {
    let phoneNumber = profileData.phoneNumber.filter("0123456789".contains)
    if phoneNumber.count == 10 {      
      if MFMessageComposeViewController.canSendText() {
        let messageVC = MFMessageComposeViewController()
        
        messageVC.recipients = [phoneNumber]
        if profileData.roasts.count > 0 {
          messageVC.body = "I just roasted you on getpear.com! 🍐 https://getpear.com/go/refer"
        } else {
          messageVC.body = "I just boasted you on getpear.com! 🍐 https://getpear.com/go/refer"
        }
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
    guard let userID = DataStore.shared.currentPearUser?.documentID,
      let userFirstName = DataStore.shared.currentPearUser?.firstName else {
        completion(.failure((errorTitle: "Please login first", errorMessage: "You muust be logged in to create profiles")))
        return
    }
  profileData.updateAuthor(authorID: userID,
                           authorFirstName: userFirstName)
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
          completion(.failure((errorTitle: "Please login first", errorMessage: "You muust be logged in to create profiles")))
        default:
          completion(.failure((errorTitle: "Oopsie",
                               errorMessage: "Our server made an oopsie woopsie.  Please try again or let us know and we will do our best to fix it ASAP (support@getpear.com)")))
        }
        
      }
    }
  }
  
}