//
//  NetworkingConfig.swift
//  Pear
//
//  Created by Avery Lamp on 3/5/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

class NetworkingConfig {
  
  // swiftlint : disable: next line
  static let secureHTTPs = "http"
  
  #if DEVMODE
  static let host: String = "10.0.0.69:1233"
  #endif
  #if PROD
  static let host: String = "koala.mit.edu"
  #endif
//  static let host: String = "koala.mit.edu"
//    static let host: String = "66.31.16.203"
  
  static let devGraphQLHost: URL = URL(string: "\(secureHTTPs)://\(host)/graphql")!
  static let graphQLHost: URL = URL(string: "\(secureHTTPs)://\(host)/graphql")!
  static let imageAPIHost: URL = URL(string: "https://u6qoh0vm77.execute-api.us-east-1.amazonaws.com/default/imageCompressorUploader")!
  static let imageAPIKey: String = "3gIpimRUcE54l1Vmq4DL56eJVGUDiymf92TH9YBJ"
  static let eulaURL: URL = URL(string: "https://getpear.com/terms-of-use")!
  static let privacyPolicyURL: URL = URL(string: "https://getpear.com/privacy-policy")!
  
}
