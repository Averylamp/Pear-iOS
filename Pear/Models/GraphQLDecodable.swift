//
//  GraphQLDecodable.swift
//  Pear
//
//  Created by Avery Lamp on 4/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
protocol GraphQLDecodable: class {
  static func graphQLAllFields() -> String
}
