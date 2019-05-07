//
//  ProfileDemographicsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class NewProfileDemographicsViewController: UIViewController {

  var locationName: String?
  var schoolName: String?
  var schoolYear: String?

  @IBOutlet var stackView: UIStackView!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(locationName: String?,
                         schoolName: String?,
                         schoolYear: String?) -> NewProfileDemographicsViewController? {
    guard let demographicsVC = R.storyboard.newProfileDemographicsViewController()
      .instantiateInitialViewController()as? NewProfileDemographicsViewController else {
      return nil
    }
    demographicsVC.locationName = locationName
    demographicsVC.schoolName = schoolName
    demographicsVC.schoolYear = schoolYear
    return demographicsVC
  }
  
}

// MARK: - Life Cycle
extension NewProfileDemographicsViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    
  }
  
  func stylizeLabel(label: UILabel) {
    if let font = R.font.openSansBold(size: 16) {
      label.font = font
    }
    label.textColor = UIColor(white: 0.2, alpha: 1.0)
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
  }
  
  func setup() {
    if let locationName = self.locationName {
      self.addItem(text: locationName, iconImage: R.image.iconLocationMarker())
    }
    if self.schoolName != nil || self.schoolYear != nil {
      var schoolText = ""
      if let schoolName = self.schoolName {
        schoolText += schoolName
      }
      if let schoolYear = self.schoolYear {
        if schoolText.count > 0 {
          schoolText += ", " + schoolYear
        } else {
          schoolText += schoolYear
        }
      }
      if schoolText.count > 0 {
        self.addItem(text: schoolText, iconImage: R.image.schoolIcon())
      }
    }
  }
  
  func addItem(text: String, iconImage: UIImage?) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    let textLabel = UILabel()
    self.stylizeLabel(label: textLabel)
    containerView.addSubview(textLabel)
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.addConstraints([
      NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal,
                         toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: textLabel, attribute: .height, relatedBy: .equal,
                         toItem: containerView, attribute: .height, multiplier: 1.0, constant: -10.0),
      NSLayoutConstraint(item: textLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -8.0)
      ])
    
    if let iconImage = iconImage {
      let imageView = UIImageView()
      imageView.contentMode = .scaleAspectFit
      imageView.image = iconImage
      imageView.translatesAutoresizingMaskIntoConstraints = false
      containerView.addSubview(imageView)
      imageView.addConstraints([
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal,
                           toItem: imageView, attribute: .height, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0)
        ])
      containerView.addConstraints([
        NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal,
                           toItem: containerView, attribute: .left, multiplier: 1.0, constant: 8.0),
        NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal,
                           toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal, toItem: textLabel, attribute: .left, multiplier: 1.0, constant: -8)
        ])
    } else {
      containerView.addConstraint(NSLayoutConstraint(item: textLabel, attribute: .left, relatedBy: .equal,
                                                     toItem: containerView, attribute: .left, multiplier: 1.0, constant: 8.0))
    }
    
    self.stackView.addArrangedSubview(containerView)
  }
  
}
