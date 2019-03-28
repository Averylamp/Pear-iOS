//
//  GetStartedSampleBiosViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class GetStartedSampleBiosViewController: UIViewController {
  
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var scrollView: UIScrollView!
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> GetStartedSampleBiosViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedSampleBiosViewController.self), bundle: nil)
    guard let sampleBiosVC = storyboard.instantiateInitialViewController() as? GetStartedSampleBiosViewController else { return nil }
    return sampleBiosVC
  }
  
  @IBAction func closeButtonClicked(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

// MARK: - Life Cycle
extension GetStartedSampleBiosViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupSampleProfiles()
  }
  
  func setupSampleProfiles() {
    let numProfiles = 5
    self.view.layoutIfNeeded()
    pageControl.numberOfPages = numProfiles
    for sampleProfileNumber in 0..<numProfiles {
      let cardView = UIView(frame: CGRect(x: self.scrollView.frame.width * CGFloat(sampleProfileNumber) + 40,
                                          y: 0,
                                          width: self.scrollView.frame.width - 80,
                                          height: self.scrollView.frame.height))
      cardView.layer.cornerRadius = 10
      cardView.layer.shadowRadius = 3.0
      cardView.layer.shadowColor = UIColor.black.cgColor
      cardView.layer.shadowOpacity = 0.3
      cardView.layer.shadowOffset = CGSize(width: 1, height: 1)
      cardView.addMotionEffect(MotionEffectGroupGenerator.getMotionEffectGroup(maxDistance: 10.0))
      self.scrollView.addSubview(cardView)
      
      let cardImageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: cardView.frame.size))
      cardImageView.layer.cornerRadius = 10
      cardImageView.image = UIImage(named: "onboarding-sample-profile-\((sampleProfileNumber % 3) + 1)")
      cardImageView.contentMode = .scaleAspectFit
      cardView.addSubview(cardImageView)
    }
    
    self.scrollView.showsHorizontalScrollIndicator = false
    self.scrollView.isPagingEnabled = true
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * CGFloat(numProfiles), height: self.scrollView.frame.height)
    self.scrollView.delegate = self
  }
  
}

// MARK: - @IBActions
private extension GetStartedSampleBiosViewController {
  
  @objc func pageControlChanged(sender: UIPageControl) {
    let pageIndex: Int = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
    if sender.currentPage != pageIndex {
      self.scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.width * CGFloat(sender.currentPage), y: 0), animated: true)
    }
  }
  
}

// MARK: - UIScrollViewDelegate
extension GetStartedSampleBiosViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
    pageControl.currentPage = Int(pageIndex)
  }
}
