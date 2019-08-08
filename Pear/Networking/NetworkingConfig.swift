//
//  NetworkingConfig.swift
//  Pear
//
//  Created by Avery Lamp on 3/5/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

class NetworkingConfig {
  
  static let devGraphQLURLString: String = "https://sloths.mit.edu/graphql"
  static let graphQLURLString: String = "https://koala.mit.edu/graphql"
  
  static var devGraphQLHost: URL = URL(string: devGraphQLURLString)!
  static var graphQLHost: URL = URL(string: graphQLURLString)!
  static let imageAPIHost: URL = URL(string: "https://u6qoh0vm77.execute-api.us-east-1.amazonaws.com/default/imageCompressorUploader")!
  static let imageAPIKey: String = "3gIpimRUcE54l1Vmq4DL56eJVGUDiymf92TH9YBJ"
  static let eulaURL: URL = URL(string: "https://getpear.com/terms-of-use")!
  static let privacyPolicyURL: URL = URL(string: "https://getpear.com/privacy-policy")!
  
}
