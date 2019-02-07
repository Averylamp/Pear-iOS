//
//  FakeAuthAPI.swift
//  SubtleAsianMatches
//
//  Created by Kelvin Lau on 2018-12-26.
//  Copyright © 2018 sam. All rights reserved.
//

import Foundation

struct FakeAuthAPI {}

extension FakeAuthAPI: AuthAPI {
    
    func login(with method: LoginMethod, completion: @escaping (Result<User, AuthAPIError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let user = User()
            completion(.success(user))
        }
    }
}
