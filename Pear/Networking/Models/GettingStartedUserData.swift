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
    var age: Int?
    var phoneNumber: String?
    var phoneNumberVerified: Bool = false
    var firebaseAuthToken: String?

    init(   firstName: String?,
            lastName: String?,
            age: Int?,
            phoneNumber: String?,
            firebaseAuthToken: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.phoneNumber = phoneNumber
        self.firebaseAuthToken = firebaseAuthToken
    }

    init() {

    }

}
