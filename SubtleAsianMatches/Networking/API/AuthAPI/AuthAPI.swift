//
//  AuthAPI.swift
//  SubtleAsianMatches
//
//  Created by Kelvin Lau on 2018-12-26.
//  Copyright © 2018 sam. All rights reserved.
//

enum LoginMethod {
    case firebase(token: String)
}

enum AuthAPIError: Error {
    case unknown
}

protocol AuthAPI {
    func login(with method: LoginMethod, completion: @escaping (Result<User, AuthAPIError>) -> Void)
}

