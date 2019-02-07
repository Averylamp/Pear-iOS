//
//  SAMAuthAPI.swift
//  SubtleAsianMatches
//
//  Created by Kelvin Lau on 2018-12-26.
//  Copyright © 2018 sam. All rights reserved.
//

import Firebase

struct SAMAuthAPI {
    
}

extension SAMAuthAPI: AuthAPI {
    
    func login(with method: LoginMethod, completion: @escaping (Result<User, AuthAPIError>) -> Void) {
        
    }
}


