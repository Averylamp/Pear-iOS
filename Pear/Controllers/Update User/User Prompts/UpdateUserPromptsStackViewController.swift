//
//  UpdateUserPromptsStackViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UpdateUserPromptsStackViewController: UIViewController {
  
  @IBOutlet var stackView: UIStackView!
  
  let edgeSpace: CGFloat = 20.0
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UpdateUserPromptsStackViewController? {
    guard let updateUserPromptsVC = R.storyboard.updateUserPromptsStackViewController
      .instantiateInitialViewController() else { return nil }
    return updateUserPromptsVC
  }

}

// MARK: - Life Cycle
extension UpdateUserPromptsStackViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  func setup() {
    self.addNoPromptsCard()
  }
  
  func stylize() {
    
  }
  
}

// MARK: - No Prompts
extension UpdateUserPromptsStackViewController {
  
  func addNoPromptsCard() {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    let cardView = UIButton()
    cardView.translatesAutoresizingMaskIntoConstraints = false
    cardView.backgroundColor = UIColor(red: 1.00, green: 0.93, blue: 0.88, alpha: 1.00)
    cardView.layer.cornerRadius = 12.0
    containerView.addSubview(cardView)
    containerView.addConstraints([
      NSLayoutConstraint(item: cardView, attribute: .left, relatedBy: .equal,
                         toItem: containerView, attribute: .left, multiplier: 1.0, constant: edgeSpace),
      NSLayoutConstraint(item: cardView, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -edgeSpace),
      NSLayoutConstraint(item: cardView, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 4.0),
      NSLayoutConstraint(item: cardView, attribute: .bottom, relatedBy: .equal,
                         toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -4.0)
      ])
    
    let imageView = UIImageView()
    imageView.image = R.image.meIconWarning()
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.addConstraints([
      NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil,
                         attribute: .notAnAttribute, multiplier: 1.0, constant: 24),
      NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView,
                         attribute: .height, multiplier: 1.0, constant: 0.0)
      ])
    cardView.addSubview(imageView)
    let descriptionLabel = UILabel()
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    descriptionLabel.text =  "To appear in Discovery, you need at least three prompts answered by a friend."
    if let font = R.font.openSansSemiBold(size: 14.0) {
      descriptionLabel.font = font
    }
    descriptionLabel.textColor = R.color.primaryTextColor()
    descriptionLabel.numberOfLines = 0
    cardView.addSubview(descriptionLabel)
    let addFriendLabel = UILabel()
    addFriendLabel.text = "Add a friend"
    if let font = R.font.openSansBold(size: 14.0) {
      addFriendLabel.font = font
    }
    addFriendLabel.textColor = UIColor(red: 1.00, green: 0.56, blue: 0.23, alpha: 1.00)
    addFriendLabel.translatesAutoresizingMaskIntoConstraints = false
    cardView.addSubview(addFriendLabel)
    
    // Relative Constraints
    cardView.addConstraints([
      NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal,
                         toItem: cardView, attribute: .left, multiplier: 1.0, constant: 12),
      NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal,
                         toItem: cardView, attribute: .top, multiplier: 1.0, constant: 12),
      NSLayoutConstraint(item: descriptionLabel, attribute: .left, relatedBy: .equal,
                         toItem: imageView, attribute: .right, multiplier: 1.0, constant: 8.0),
      NSLayoutConstraint(item: descriptionLabel, attribute: .left, relatedBy: .equal,
                         toItem: addFriendLabel, attribute: .left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal,
                         toItem: cardView, attribute: .top, multiplier: 1.0, constant: 8.0),
      NSLayoutConstraint(item: descriptionLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: addFriendLabel, attribute: .top, multiplier: 1.0, constant: -8.0),
      NSLayoutConstraint(item: addFriendLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: -8.0),
      NSLayoutConstraint(item: descriptionLabel, attribute: .right, relatedBy: .equal,
                         toItem: cardView, attribute: .right, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: addFriendLabel, attribute: .right, relatedBy: .equal,
                         toItem: descriptionLabel, attribute: .right, multiplier: 1.0, constant: 0.0)
      ])
    
    self.stackView.addArrangedSubview(containerView)
  }
  
}
