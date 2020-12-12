//
//  ProfileDemographicsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileInterestsViewController: UIViewController {
  
  @IBOutlet var verticalStackView: UIStackView!
  @IBOutlet weak var interestsTitleLabel: UILabel!
  var lastStackView: UIStackView!
  
  var interests: [String] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(interests: [String]) -> ProfileInterestsViewController? {
    let storyboard = UIStoryboard(name: String(describing: ProfileInterestsViewController.self), bundle: nil)
    guard let profileInterestsVC = storyboard.instantiateInitialViewController() as? ProfileInterestsViewController else { return nil }
    profileInterestsVC.interests = interests
    return profileInterestsVC
  }
  
}

// MARK: - Life Cycle
extension ProfileInterestsViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.addNewHorizontalStackView()
    self.stylize()
    self.addInterests()
  }
  
  func stylize() {
    self.interestsTitleLabel.stylizeProfileSectionTitleLabel()
    self.interestsTitleLabel.text = "Interests"
    
  }
  
  func addNewHorizontalStackView() {
    let stackViewContainer = UIView()
    stackViewContainer.translatesAutoresizingMaskIntoConstraints = false
    stackViewContainer.addConstraint(NSLayoutConstraint(item: stackViewContainer, attribute: .height, relatedBy: .equal,
                                               toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50))
    let horizontalStackView = UIStackView()
    horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
    stackViewContainer.addSubview(horizontalStackView)
//    horizontalStackView.spacing = 16
    horizontalStackView.axis = .horizontal
    stackViewContainer.addConstraints([
      NSLayoutConstraint(item: horizontalStackView, attribute: .left, relatedBy: .equal,
                         toItem: stackViewContainer, attribute: .left, multiplier: 1.0, constant: 16),
      NSLayoutConstraint(item: horizontalStackView, attribute: .right, relatedBy: .equal,
                         toItem: stackViewContainer, attribute: .right, multiplier: 1.0, constant: -16),
      NSLayoutConstraint(item: horizontalStackView, attribute: .top, relatedBy: .equal,
                         toItem: stackViewContainer, attribute: .top, multiplier: 1.0, constant: 8),
      NSLayoutConstraint(item: horizontalStackView, attribute: .bottom, relatedBy: .equal,
                         toItem: stackViewContainer, attribute: .bottom, multiplier: 1.0, constant: -8)
      ])
    
    self.verticalStackView.addArrangedSubview(stackViewContainer)
    self.lastStackView = horizontalStackView
  }
  
  func addInterests() {
    for interest in self.interests {
      let interestTag = createTagView(text: interest, image: nil)
      self.lastStackView.addArrangedSubview(interestTag)
      self.lastStackView.layoutIfNeeded()
      interestTag.layer.cornerRadius = interestTag.frame.height / 2
      interestTag.backgroundColor = R.color.tagBubbleColor()!
      if self.lastStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width >= self.lastStackView.frame.width {
        self.lastStackView.removeArrangedSubview(interestTag)
        let placeholderView = UIView()
        placeholderView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.lastStackView.addArrangedSubview(placeholderView)
        self.addNewHorizontalStackView()
        self.lastStackView.addArrangedSubview(interestTag)
      }
      self.addSpacerView(width: 16)
    }
    let placeholderView = UIView()
    placeholderView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    self.lastStackView.addArrangedSubview(placeholderView)
  }
  
  func addSpacerView(width: CGFloat) {
    let spacer = UIView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    spacer.addConstraint(NSLayoutConstraint(item: spacer, attribute: .width, relatedBy: .lessThanOrEqual,
                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width))
    spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    self.lastStackView.addArrangedSubview(spacer)
  }
  
  func createTagView(text: String, image: UIImage?) -> UIView {
    let fullView = UIView()
    
    let textLabel = UILabel()
    fullView.addSubview(textLabel)
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    textLabel.text = text
    textLabel.stylizeTagViewLabel()
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
//      fullView.intrinsicContentSize = CGSize(width: textLabel.sizeThatFits(CGSize(width: CGFloat.infinity, height: 34)).width + 32 + , height: 34)
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
      
//      fullView.intrinsicContentSize = CGSize(width: textLabel.sizeThatFits(CGSize(width: CGFloat.infinity, height: 34)).width + 32, height: 34)
    }
    return fullView
  }
  
}
