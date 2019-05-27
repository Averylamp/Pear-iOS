//
//  DiscoveryDecisionViewController+Tooltips.swift
//  Pear
//
//  Created by Avery Lamp on 5/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import UIKit
// MARK: Onboarding Overlays
extension DiscoveryDecisionViewController {
  
  func createOverlay(frame: CGRect,
                     xOffset: CGFloat,
                     yOffset: CGFloat,
                     labelText: String,
                     stepNumber: Int) -> UIView {
    // Step 1
    let overlayView = UIView(frame: frame)
    overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    // Step 2
    let path = CGMutablePath()
    path.addArc(center: CGPoint(x: xOffset, y: yOffset),
                radius: 38.0,
                startAngle: 0.0,
                endAngle: 2.0 * .pi,
                clockwise: false)
    path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))
    // Step 3
    let maskLayer = CAShapeLayer()
    maskLayer.backgroundColor = UIColor.black.cgColor
    maskLayer.path = path
    maskLayer.fillRule = .evenOdd
    // Step 4
    overlayView.layer.mask = maskLayer
    overlayView.clipsToBounds = true
    
    // add UILabel
    let labelView = UILabel(frame: CGRect(x: 20, y: self.view.frame.height - 300, width: self.view.frame.width - 100, height: 110))
    labelView.numberOfLines = 0
    labelView.textAlignment = .left
    labelView.text = labelText
    labelView.textColor = .white
    if let font = R.font.openSansExtraBold(size: 24) {
      labelView.font = font
    }
    overlayView.addSubview(labelView)
    labelView.translatesAutoresizingMaskIntoConstraints = false
    overlayView.addConstraints([
      NSLayoutConstraint(item: labelView, attribute: .bottom, relatedBy: .equal,
                         toItem: overlayView, attribute: .bottom, multiplier: 1.0, constant: -200),
      NSLayoutConstraint(item: labelView, attribute: .left, relatedBy: .equal,
                         toItem: overlayView, attribute: .left, multiplier: 1.0, constant: 20),
      NSLayoutConstraint(item: labelView, attribute: .right, relatedBy: .equal,
                         toItem: overlayView, attribute: .right, multiplier: 1.0, constant: -80)
      ])
    
    // add number icons
    let imageView1 = UIImageView(image: stepNumber == 1 ? R.image.selected1(): R.image.unselected1())
    imageView1.translatesAutoresizingMaskIntoConstraints = false
    imageView1.contentMode = .scaleAspectFit
    overlayView.addSubview(imageView1)
    imageView1.addConstraints([
      NSLayoutConstraint(item: imageView1, attribute: .width, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24.0),
      NSLayoutConstraint(item: imageView1, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24.0)
      ])
    overlayView.addConstraints([
      NSLayoutConstraint(item: imageView1, attribute: .bottom, relatedBy: .equal,
                         toItem: labelView, attribute: .top, multiplier: 1.0, constant: -10),
      NSLayoutConstraint(item: imageView1, attribute: .left, relatedBy: .equal,
                         toItem: labelView, attribute: .left, multiplier: 1.0, constant: 0)
      ])
    
    let imageView2 = UIImageView(image: stepNumber == 2 ? R.image.selected2(): R.image.unselected2())
    imageView2.translatesAutoresizingMaskIntoConstraints = false
    imageView2.contentMode = .scaleAspectFit
    overlayView.addSubview(imageView2)
    imageView2.addConstraints([
      NSLayoutConstraint(item: imageView2, attribute: .width, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24.0),
      NSLayoutConstraint(item: imageView2, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24.0)
      ])
    overlayView.addConstraints([
      NSLayoutConstraint(item: imageView2, attribute: .bottom, relatedBy: .equal,
                         toItem: labelView, attribute: .top, multiplier: 1.0, constant: -10),
      NSLayoutConstraint(item: imageView2, attribute: .left, relatedBy: .equal,
                         toItem: imageView1, attribute: .right, multiplier: 1.0, constant: 7)
      ])
    
    let imageView3 = UIImageView(image: stepNumber == 3 ? R.image.selected3() : R.image.unselected3())
    imageView3.translatesAutoresizingMaskIntoConstraints = false
    imageView3.contentMode = .scaleAspectFit
    overlayView.addSubview(imageView3)
    imageView3.addConstraints([
      NSLayoutConstraint(item: imageView3, attribute: .width, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24.0),
      NSLayoutConstraint(item: imageView3, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24.0)
      ])
    overlayView.addConstraints([
      NSLayoutConstraint(item: imageView3, attribute: .bottom, relatedBy: .equal,
                         toItem: labelView, attribute: .top, multiplier: 1.0, constant: -10),
      NSLayoutConstraint(item: imageView3, attribute: .left, relatedBy: .equal,
                         toItem: imageView2, attribute: .right, multiplier: 1.0, constant: 7)
      ])
    
    return overlayView
  }
  
  @objc func onboardingOverlay1() {
    guard let profileVC = self.currentDiscoveryProfileVC else {
      return
    }
    DispatchQueue.main.async {
      let likeOverlay = self.createOverlay(frame: self.view.frame,
                                           xOffset: profileVC.likeButton.center.x,
                                           yOffset: profileVC.likeButton.center.y,
                                           labelText: "Tap the heart to send a like",
                                           stepNumber: 1)
      let gesture = UITapGestureRecognizer(target: self, action: #selector (self.onboardingOverlay2(_:)))
      likeOverlay.addGestureRecognizer(gesture)
      self.view.addSubview(likeOverlay)
      likeOverlay.alpha = 0.0
      UIView.animate(withDuration: 0.6, animations: {
        likeOverlay.alpha = 1.0
      })
    }
  }
  
  @objc func onboardingOverlay2(_ sender: UITapGestureRecognizer) {
    guard let profileVC = self.currentDiscoveryProfileVC else {
      return
    }
    DispatchQueue.main.async {
      if let likeOverlay = sender.view {
        let pearOverlay = self.createOverlay(frame: self.view.frame,
                                             xOffset: profileVC.pearButton.center.x,
                                             yOffset: profileVC.pearButton.center.y,
                                             labelText: "Tap the Pear to match your friend",
                                             stepNumber: 2)
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.onboardingOverlay3(_:)))
        pearOverlay.addGestureRecognizer(gesture)
        pearOverlay.alpha = 0.0
        self.view.addSubview(pearOverlay)
        UIView.animate(withDuration: 0.6, animations: {
          pearOverlay.alpha = 1.0
          likeOverlay.alpha = 0.0
        }, completion: { (_) in
          likeOverlay.removeFromSuperview()
        })
      }
    }
  }
  
  @objc func onboardingOverlay3(_ sender: UITapGestureRecognizer) {
    guard let profileVC = self.currentDiscoveryProfileVC else {
      return
    }
    DispatchQueue.main.async {
      if let pearOverlay = sender.view {
        let skipOverlay = self.createOverlay(frame: self.view.frame,
                                             xOffset: profileVC.skipButton.center.x,
                                             yOffset: profileVC.skipButton.center.y,
                                             labelText: "Tap the X to skip this profile",
                                             stepNumber: 3)
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.dismissOverlay(_:)))
        skipOverlay.addGestureRecognizer(gesture)
        self.view.addSubview(skipOverlay)
        skipOverlay.alpha = 0.0
        UIView.animate(withDuration: 0.6, animations: {
          pearOverlay.alpha = 0.0
          skipOverlay.alpha = 1.0
        }, completion: { (_) in
          pearOverlay.removeFromSuperview()
        })
      }
    }
  }
  
  @objc func dismissOverlay(_ sender: UITapGestureRecognizer) {
    DataStore.shared.setFlagToDefaults(value: true, flag: .hasCompletedDiscoveryOnboarding)
    Analytics.logEvent(AnalyticsEventTutorialComplete, parameters: nil)
    DispatchQueue.main.async {
      if let skipOverlay = sender.view {
        UIView.animate(withDuration: 0.3, animations: {
          skipOverlay.alpha = 0.0
        }, completion: { (_) in
          skipOverlay.removeFromSuperview()
        })
      }
    }
  }
  
}
