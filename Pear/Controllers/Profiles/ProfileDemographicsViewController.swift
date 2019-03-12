//
//  ProfileDemographicsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileDemographicsViewController: UIViewController {
  
  @IBOutlet weak var firstNameLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  
  var firstName: String!
  var age: Int!
  var gender: GenderEnum!
  var locationName: String?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(firstName: String, age: Int, gender: GenderEnum, locationName: String? = nil) -> ProfileDemographicsViewController? {
    let storyboard = UIStoryboard(name: String(describing: ProfileDemographicsViewController.self), bundle: nil)
    guard let profileStackViewVC = storyboard.instantiateInitialViewController() as? ProfileDemographicsViewController else { return nil }
    profileStackViewVC.firstName = firstName
    profileStackViewVC.age = age
    profileStackViewVC.gender = gender
    profileStackViewVC.locationName = locationName
    return profileStackViewVC
  }
  
}

// MARK: - Life Cycle
extension ProfileDemographicsViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.firstNameLabel.stylizeTitleLabel()
    self.firstNameLabel.text = self.firstName
    
    let ageIcon = createTagView(text: "\(self.age!)", image: UIImage(named: "profiles-icon-age"))
    let genderIcon = createTagView(text: self.gender.rawValue, image: nil)
    
    var tagViews = [ageIcon, genderIcon]
    
    if let locationName = self.locationName {
      let locationTagView = createTagView(text: locationName, image: nil)
      tagViews.append(locationTagView)
    }
    
    for tagView in tagViews {
      tagView.layer.cornerRadius = 25
      tagView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.00)
      self.stackView.addArrangedSubview(tagView)
    }
    
  }
  
  func createTagView(text: String, image: UIImage?) -> UIView {
    let fullView = UIView()
    
    let textLabel = UILabel()
    fullView.addSubview(textLabel)
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    textLabel.text = text
    textLabel.stylizeSubtitleLabel()
    if let image = image {
      let imageView = UIImageView(image: image)
      fullView.addSubview(imageView)
      imageView.contentMode = .scaleAspectFit
      imageView.translatesAutoresizingMaskIntoConstraints = false
      
      fullView.addConstraints([
        NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal,
                           toItem: fullView, attribute: .top, multiplier: 1.0, constant: 8),
        NSLayoutConstraint(item: textLabel, attribute: .bottom, relatedBy: .equal,
                           toItem: fullView, attribute: .bottom, multiplier: 1.0, constant: -8),
        NSLayoutConstraint(item: textLabel, attribute: .left, relatedBy: .equal,
                           toItem: imageView, attribute: .right, multiplier: 1.0, constant: 8),
        NSLayoutConstraint(item: textLabel, attribute: .right, relatedBy: .equal,
                           toItem: fullView, attribute: .right, multiplier: 1.0, constant: -16),
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal,
                           toItem: imageView, attribute: .height, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal,
                           toItem: textLabel, attribute: .lastBaseline, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 26),
        NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal,
                           toItem: fullView, attribute: .left, multiplier: 1.0, constant: 16)
        ])
      
    } else {
      fullView.addConstraints([
        NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal,
                           toItem: fullView, attribute: .top, multiplier: 1.0, constant: 8),
        NSLayoutConstraint(item: textLabel, attribute: .bottom, relatedBy: .equal,
                           toItem: fullView, attribute: .bottom, multiplier: 1.0, constant: -8),
        NSLayoutConstraint(item: textLabel, attribute: .left, relatedBy: .equal,
                           toItem: fullView, attribute: .left, multiplier: 1.0, constant: 16),
        NSLayoutConstraint(item: textLabel, attribute: .right, relatedBy: .equal,
                           toItem: fullView, attribute: .right, multiplier: 1.0, constant: -16)
        ])
    }
    
    return fullView
  }
  
}
