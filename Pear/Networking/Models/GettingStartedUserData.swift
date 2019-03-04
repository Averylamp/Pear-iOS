//
//  GettingStartedUserData.swift
//  Pear
//
//  Created by Avery Lamp on 2/27/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class GettingStartedUserData: CustomStringConvertible {
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var emailVerified: Bool = false
    var age: Int?
    var gender: GenderEnum?
    var birthdate: Date?
    var phoneNumber: String?
    var phoneNumberVerified: Bool = false
    var primaryAuth: AuthCredential?
    var firebaseToken: String?
    var firebaseAuthID: String?
    var facebookId: String?
    var facebookAccessToken: String?
    
    init(   firstName: String?,
            lastName: String?,
            email: String?,
            age: Int?,
            phoneNumber: String?,
            firebaseAuthToken: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.age = age
        self.phoneNumber = phoneNumber
        self.firebaseAuthID = firebaseAuthToken
    }
    
    init() {
        
    }
    var description: String {
        return "**** GettingStartedUserData\n " + """
        firstName: \(String(describing: firstName)),
        lastName: \(String(describing: lastName)),
        email: \(String(describing: email)),
        emailVerified: \(String(describing: emailVerified)),
        age: \(String(describing: age)),
        gender: \(String(describing: gender)),
        birthdate: \(String(describing: birthdate)),
        phoneNumber: \(String(describing: phoneNumber)),
        phoneNumberVerified: \(String(describing: phoneNumberVerified)),
        firebaseToken: \(String(describing: firebaseToken)),
        firebaseAuthID: \(String(describing: firebaseAuthID)),
        facebookId: \(String(describing: facebookId)),
        facebookAccessToken: \(String(describing: facebookAccessToken)),
        """
    }
    
    func getNextInputViewController() -> UIViewController? {
        
        if self.email == nil {
            guard let emailInputVC = GetStartedEmailProviderViewController.instantiate(gettingStartedUserData: self) else {
                print("Failed to create Email Provider VC")
                return nil
            }
            return emailInputVC
        }
        
        if self.firstName == nil {
            guard let userFirstNameVC = GetStartedUserFirstNameViewController.instantiate(gettingStartedUserData: self) else {
                print("Failed to start User First Name VC: ")
                return nil
            }
            return userFirstNameVC
        }
        
        if self.lastName == nil {
            guard let userLastNameVC = GetStartedUserLastNameViewController.instantiate(gettingStartedUserData: self) else {
                print("Failed to start User Last Name VC: ")
                return nil
            }
            return userLastNameVC
        }
        
        if self.age  == nil {
            print("User Åge Missing")
            print("RED FLAGSS")
        }
        
        if self.birthdate  == nil {
            print("User Birthday Missing")
            print("RED FLAGSS")
        }
        
        if self.phoneNumber == nil {
            guard let phoneInputVC = GetStartedValidatePhoneNumberViewController.instantiate(gettingStartedUserData: self) else {
                print("Failed to create Phone Number VC")
                return nil
            }
            return phoneInputVC
        }
        
        return nil
    }
    
}
