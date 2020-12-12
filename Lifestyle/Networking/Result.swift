//
//  Result.swift
//  SubtleAsianMatches
//
//  Created by Kelvin Lau on 2018-12-26.
//  Copyright © 2018 sam. All rights reserved.
//

enum Result<T, Error> {
  case success(T)
  case failure(Error)
}
