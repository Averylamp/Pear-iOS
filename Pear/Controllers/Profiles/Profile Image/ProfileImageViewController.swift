//
//  ProfileImageViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

import SDWebImage
class ProfileImageViewController: UIViewController {
  
  var image: UIImage?
  var imageContainer: ImageContainer?
  @IBOutlet var imageView: UIImageView!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(image: UIImage) -> ProfileImageViewController? {
    let storyboard = UIStoryboard(name: String(describing: ProfileImageViewController.self), bundle: nil)
    guard let profileStackViewVC = storyboard.instantiateInitialViewController() as? ProfileImageViewController else { return nil }
    profileStackViewVC.image = image
    return profileStackViewVC
  }
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(imageContainer: ImageContainer) -> ProfileImageViewController? {
    let storyboard = UIStoryboard(name: String(describing: ProfileImageViewController.self), bundle: nil)
    guard let profileStackViewVC = storyboard.instantiateInitialViewController() as? ProfileImageViewController else { return nil }
    profileStackViewVC.imageContainer = imageContainer
    return profileStackViewVC
  }
  
}

// MARK: - Life Cycle
extension ProfileImageViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.stylize()
  }
  
  func stylize() {
    
    self.imageView.contentMode = .scaleAspectFill
    self.imageView.clipsToBounds = true
    if let image = self.image {
      self.imageView.image = image
    } else if let imageContainer = self.imageContainer,
      let imageURL = URL(string: imageContainer.large.imageURL) {
      self.imageView.sd_setImage(with: imageURL, completed: nil)
    }
    self.imageView.addConstraint(NSLayoutConstraint(item: self.imageView!, attribute: .width, relatedBy: .equal,
                                                    toItem: self.imageView, attribute: .height, multiplier: 1.0, constant: 0.0))
  }
  
}
