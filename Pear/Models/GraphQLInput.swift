//
//  GraphQLInput.swift
//  Pear
//
//  Created by Avery Lamp on 4/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

protocol GraphQLInput: class {
  
  func toGraphQLInput() -> [String: Any]
  
}
