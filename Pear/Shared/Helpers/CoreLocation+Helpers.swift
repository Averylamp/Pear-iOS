//
//  CoreLocation+Helpers.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
  func distanceMiles(other: CLLocationCoordinate2D) -> Double {
    let cl1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
    let cl2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
    let metersDistance = cl1.distance(from: cl2)
    return metersDistance / 1609.0
  }
}
