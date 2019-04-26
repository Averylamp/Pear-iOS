//
//  ProfileDemographicsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileDemographicsViewController: UIViewController {
    
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var extraInfoStackView: UIStackView!
  @IBOutlet weak var vibesStackView: UIStackView!
  
  var firstName: String?
  var age: Int?
  var locationName: String?
  var schoolName: String?
  var vibes: [VibeItem] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(firstName: String?, age: Int?, schoolName: String? = nil, locationName: String? = nil, vibes: [VibeItem] = []) -> ProfileDemographicsViewController? {
    let storyboard = UIStoryboard(name: String(describing: ProfileDemographicsViewController.self), bundle: nil)
    guard let demograpicsVC = storyboard.instantiateInitialViewController() as? ProfileDemographicsViewController else { return nil }
    demograpicsVC.firstName = firstName
    demograpicsVC.age = age
    demograpicsVC.schoolName = schoolName
    demograpicsVC.locationName = locationName
    demograpicsVC.vibes = vibes
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
    if let firstName = self.firstName {
      if let age = self.age {
        self.nameLabel.text = "\(firstName), \(age)"
      } else {
        self.nameLabel.text = "\(firstName)"
      }
    } else {
      self.nameLabel.text = "¯\\_(ツ)_/¯"
    }
    
    for vibe in self.vibes {
      let vibeImageView = UIImageView()
      vibeImageView.translatesAutoresizingMaskIntoConstraints = false
      vibeImageView.contentMode = .scaleAspectFit
      vibeImageView.addConstraint(NSLayoutConstraint(item: vibeImageView, attribute: .width, relatedBy: .equal,
                                                     toItem: vibeImageView, attribute: .height, multiplier: 1.0, constant: 0.0))
      if let image = vibe.icon?.syncUIImageFetch() {
        vibeImageView.image = image
      } else if let assetURL = vibe.icon?.assetURL {
        vibeImageView.sd_setImage(with: assetURL, completed: nil)
      } else {
        continue
      }
      self.vibesStackView.addArrangedSubview(vibeImageView)
      
    }
    
    if let locationName = self.locationName {
      self.extraInfoStackView.addArrangedSubview(self.generateInfoTagItem(name: locationName, icon: R.image.iconLocationMarker()))
    }
    
    if let schoolName = self.schoolName {
      self.extraInfoStackView.addArrangedSubview(self.generateInfoTagItem(name: schoolName, icon: R.image.iconSchool()))
    }

  }
  
  func generateInfoTagItem(name: String, icon: UIImage?) -> UIView {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    let tagLabel = UILabel()
    tagLabel.translatesAutoresizingMaskIntoConstraints = false
    if let font = R.font.openSansBold(size: 12) {
      tagLabel.font = font
    }
    tagLabel.textColor = UIColor(white: 0.2, alpha: 0.5)
    tagLabel.text = name
    containerView.addSubview(tagLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: tagLabel, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: tagLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: tagLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -8)
      ])
    
    if let icon = icon {
      let imageView = UIImageView()
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.contentMode = .scaleAspectFit
      imageView.image = icon
      imageView.alpha = 0.5
      containerView.addSubview(imageView)
      imageView.addConstraints([
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25),
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal,
                           toItem: imageView, attribute: .height, multiplier: 1.0, constant: 0)
        ])
      containerView.addConstraints([
        NSLayoutConstraint(item: tagLabel, attribute: .left, relatedBy: .equal,
                           toItem: imageView, attribute: .right, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal,
                           toItem: containerView, attribute: .left, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal,
                           toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
    } else {
      containerView.addConstraints([
        NSLayoutConstraint(item: tagLabel, attribute: .left, relatedBy: .equal,
                           toItem: containerView, attribute: .left, multiplier: 1.0, constant: 0.0)
        ])
      
    }
    return containerView
  }

}
