//
//  NetworkingConfig.swift
//  Pear
//
//  Created by Avery Lamp on 3/5/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

class NetworkingConfig {
  
  //  static let host: String = "sloths.mit.edu"
    static let host: String = "koala.mit.edu"
//  static let host: String = "66.31.16.203"
  
  static let devGraphQLHost: URL = URL(string: "http://\(host):1234/graphql")!
  static let graphQLHost: URL = URL(string: "http://\(host):1234/graphql")!
  static let imageAPIHost: URL = URL(string: "http://\(host):1337")!
  
}
