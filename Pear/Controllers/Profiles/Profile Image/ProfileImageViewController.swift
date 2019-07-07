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
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet var imageView: UIImageView!
  
  var timestampString: String?
  var writtenByName: String?

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
  class func instantiate(imageContainer: ImageContainer, timestampString: String? = nil, writtenByName: String? = nil) -> ProfileImageViewController? {
    let storyboard = UIStoryboard(name: String(describing: ProfileImageViewController.self), bundle: nil)
    guard let profileStackViewVC = storyboard.instantiateInitialViewController() as? ProfileImageViewController else { return nil }
    profileStackViewVC.imageContainer = imageContainer
    profileStackViewVC.timestampString = timestampString
    profileStackViewVC.writtenByName = writtenByName
    return profileStackViewVC
  }
  
}

// MARK: - Life Cycle
extension ProfileImageViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  /// Setup should only be called once
  func setup() {
    self.imageView.contentMode = .scaleAspectFill
    self.imageView.clipsToBounds = true
    self.scrollView.maximumZoomScale = 2.0
    self.scrollView.minimumZoomScale = 1.0
    self.scrollView.delegate = self
  }
  
  /// Stylize can be called more than once
  func stylize() {
    if let image = self.image {
      self.imageView.image = image
    } else if let imageContainer = self.imageContainer,
      let imageURL = URL(string: imageContainer.large.imageURL) {
      self.imageView.sd_setImage(with: imageURL, completed: nil)
    }
  }
  
}

// MARK: Scroll View Delegate
extension ProfileImageViewController: UIScrollViewDelegate {
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return self.imageView
  }
  
  func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    UIView.animate(withDuration: 0.3) {
      self.scrollView.zoomScale = 1.0
    }
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    self.scrollView.zoomScale = max(self.scrollView.zoomScale, 1.0)
  }
  
}
