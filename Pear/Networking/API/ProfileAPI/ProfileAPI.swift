//
//  ProfileAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

protocol ProfileAPI {
  func createNewDetachedProfile(gettingStartedUserProfileData: GettingStartedUserProfileData,
                                completion: @escaping(Result<PearDetachedProfile, Error>) -> Void)
  func checkDetachedProfiles(phoneNumber: String, completion: @escaping(Result<[PearDetachedProfile], Error>) -> Void)
}
