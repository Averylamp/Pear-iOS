//
//  NetworkingConfig.swift
//  Pear
//
//  Created by Avery Lamp on 3/5/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation

class NetworkingConfig {
    
    #if DEBUG
    static let devGraphQLHost: URL = URL(string: "http://66.31.16.203:1234/graphql")!
    static let graphQLHost: URL = URL(string: "http://66.31.16.203:1234/graphql")!
    static let imageAPIHost: URL = URL(string: "http://koala.mit.edu:1337")!
    #endif
    
}