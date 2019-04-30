//
//  UIViewController+ProfileCreationProtocol.swift
//  Pear
//
//  Created by Avery Lamp on 4/30/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import ContactsUI

protocol ProfileCreationProtocol {
  func didSelectContact(contact: CNContact)
  func didSelectContactProperty(contactProperty: CNContactProperty)
  func receivedProfileCreationData(creationData: ProfileCreationData)
  func recievedProfileCreationError(title: String, message: String?)
  func getContactsPicker() -> CNContactPickerViewController
}

extension ProfileCreationProtocol {
  
  func getContactsPicker() -> CNContactPickerViewController {
    let cnPicker = CNContactPickerViewController()
    cnPicker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count >= 1", argumentArray: nil)
    cnPicker.predicateForSelectionOfContact = NSPredicate(format: "phoneNumbers.@count == 1", argumentArray: nil)
    //    cnPicker.predicateForSelectionOfProperty = NSPredicate(format: "key == 'phoneNumbers'", argumentArray: nil)
    cnPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey]
    return cnPicker
  }
  
  func didSelectContact(contact: CNContact) {
    if let phoneNumberContactValue = contact.phoneNumbers.first?.value {
      self.processContact(contact: contact, phoneNumberValue: phoneNumberContactValue)
    } else {
      self.recievedProfileCreationError(title: "An unknown error occured",
                                        message: "We have been notified and are working to resolve this issue 😬")
      
      let contactData: [String: Any] = [
        "firstName": contact.givenName,
        "lastName": contact.familyName,
        "phoneNumbers": contact.phoneNumbers.map({ $0.value.stringValue })
      ]
      SentryHelper.generateSentryMessageEvent(level: .error,
                                              message: "Invalid_Contact",
                                              tags: [:],
                                              extra: contactData)
      return
    }
    
  }
  
  func didSelectContactProperty(contactProperty: CNContactProperty) {
    if let contactValue = contactProperty.value as? CNPhoneNumber {
      self.processContact(contact: contactProperty.contact, phoneNumberValue: contactValue)
    } else {
      
    }
  }
  
  func processContact(contact: CNContact, phoneNumberValue: CNPhoneNumber) {
    var phoneNumber = phoneNumberValue.stringValue
    phoneNumber = phoneNumber.filter("0123456789".contains)
    if phoneNumber.count == 11 && phoneNumber[0] == "1" {
      phoneNumber = phoneNumber[1..<11]
    }
    if phoneNumber.count != 10 {
      self.recievedProfileCreationError(title: "Not a Valid Number", message: "Contact must have a valid US phone number")
      let contactData: [String: Any] = [
        "firstName": contact.givenName,
        "lastName": contact.familyName,
        "phoneNumbers": contact.phoneNumbers.map({ $0.value.stringValue })
      ]
      SentryHelper.generateSentryMessageEvent(level: .error,
                                              message: "Invalid_Phone_Number",
                                              tags: ["number": phoneNumber],
                                              extra: contactData)
      return
    }
    
     let createProfileData = ProfileCreationData(contact: contact, phoneNumber: phoneNumber)
    self.receivedProfileCreationData(creationData: createProfileData)
  }
  
}
