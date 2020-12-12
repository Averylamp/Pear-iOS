//
//  MotionEffectGroupGenerator.swift
//  Pear
//
//  Created by Avery Lamp on 2/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class MotionEffectGroupGenerator {
  
  class func getMotionEffectGroup(xDistance: CGFloat, yDistance: CGFloat) -> UIMotionEffectGroup {
    let xMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
    xMotion.minimumRelativeValue = -xDistance
    xMotion.maximumRelativeValue = xDistance
    
    let yMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
    yMotion.minimumRelativeValue = -yDistance
    yMotion.maximumRelativeValue = yDistance
    
    let motionEffectGroup = UIMotionEffectGroup()
    motionEffectGroup.motionEffects = [xMotion, yMotion]
    return motionEffectGroup
  }
  
  class func getMotionEffectGroup(maxDistance: CGFloat) -> UIMotionEffectGroup {
    return getMotionEffectGroup(xDistance: maxDistance, yDistance: maxDistance)
  }
  
}
