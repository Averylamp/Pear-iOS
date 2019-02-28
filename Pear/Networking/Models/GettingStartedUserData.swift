//
//  GettingStartedUserData.swift
//  Pear
//
//  Created by Avery Lamp on 2/27/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation
import UIKit

class GettingStartedUserData {

    var firstName: String?
    var lastName: String?
    var email: String?
    var emailVerified: Bool = false
    var age: Int?
    var birthdate: Date?
    var phoneNumber: String?
    var phoneNumberVerified: Bool = false
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

}
