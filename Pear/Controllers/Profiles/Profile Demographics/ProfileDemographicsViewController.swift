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
  @IBOutlet weak var scrollView: UIScrollView!
    
  var firstName: String!
  var age: Int?
  var gender: String!
  var schoolName: String?
  var locationName: String?
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(firstName: String, age: Int?, gender: String, schoolName: String? = nil, locationName: String? = nil) -> ProfileDemographicsViewController? {
    let storyboard = UIStoryboard(name: String(describing: ProfileDemographicsViewController.self), bundle: nil)
    guard let demograpicsVC = storyboard.instantiateInitialViewController() as? ProfileDemographicsViewController else { return nil }
    demograpicsVC.firstName = firstName
    demograpicsVC.age = age
    demograpicsVC.gender = gender
    demograpicsVC.schoolName = schoolName
    demograpicsVC.locationName = locationName
    return demograpicsVC
  }
  
}

// MARK: - Life Cycle
extension ProfileDemographicsViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.firstNameLabel.stylizeFullPageNameLabel()
    self.firstNameLabel.text = self.firstName
    var tagViews: [UIView] = []
    
    if let age = self.age {
      let ageIcon = createTagView(text: "\(age)", image: R.image.profileIconAge())
      tagViews = [ageIcon]
    }
    
    if let schoolName = self.schoolName {
      let schoolTagView = createTagView(text: schoolName, image: R.image.profileIconSchool())
      tagViews.append(schoolTagView)
    }
    
    if let locationName = self.locationName {
      let locationTagView = createTagView(text: locationName, image: R.image.profileIconLocation())
      tagViews.append(locationTagView)
    }
    
    for tagView in tagViews {
      tagView.layer.cornerRadius = 25
      tagView.backgroundColor = R.color.tagBubbleColor()!
      self.stackView.addArrangedSubview(tagView)
    }
    
    if tagViews.count == 0 {
      self.scrollView.isHidden = true
    }
    
  }
  
  func createTagView(text: String, image: UIImage?) -> UIView {
    let fullView = UIView()
    
    let textLabel = UILabel()
    fullView.addSubview(textLabel)
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    textLabel.text = text
    textLabel.stylizeTagLabel()
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
