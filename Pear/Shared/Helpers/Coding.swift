//
//  File.swift
//  Pear
//
//  Created by Avery Lamp on 3/11/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

enum DecodableError: Error {
  case isNotJSONObject
}

extension Decodable {
  init(dictionary: [String: Any]) throws {
    guard JSONSerialization.isValidJSONObject(dictionary) else { throw DecodableError.isNotJSONObject }
    let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
    let decodedObject = try JSONDecoder().decode(Self.self, from: jsonData)
    self = decodedObject
  }
}
