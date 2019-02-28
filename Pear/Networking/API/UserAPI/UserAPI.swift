//
//  UserAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/24/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation

protocol UserAPI {
    func createNewUser(with gettingStartedUserData: GettingStartedUserData, completion: @escaping (Result<PearUser, Error>) -> Void)
}
