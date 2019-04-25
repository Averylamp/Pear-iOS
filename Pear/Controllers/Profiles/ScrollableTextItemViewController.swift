//
//  ScrollableTextItemViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ScrollableTextItemViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var scrollContentView: UIView!
  
  var items: [TextContentItem] = []
  var intrinsicContentHeights: [CGFloat] = []
  var userName: String?
  var maxLines: Int = 0
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(items: [TextContentItem], userName: String? = nil, maxLines: Int = 0) -> ScrollableTextItemViewController? {
    guard let scrollingItemVC = R.storyboard.scrollableTextItemViewController()
      .instantiateInitialViewController() as? ScrollableTextItemViewController else { return nil }
    scrollingItemVC.items = items
    scrollingItemVC.userName = userName
    scrollingItemVC.maxLines = maxLines
    return scrollingItemVC
  }
  
}

extension ScrollableTextItemViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.scrollView.delegate = self
  }
  
  func stylize() {
    
  }
  
  func setup() {
    self.addItems()
  }
  
  func addItems() {
    self.view.layoutIfNeeded()
    print(self.items)
    var count = 0
    for item in self.items {
      var viewController: UIViewController?
      if let item = item as? BioItem {
        guard let bioItemVC = ProfileBioViewController.instantiate(bioItem: item, maxLines: maxLines) else {
          print("Failed to create Bio Item VC")
          return
        }
        viewController = bioItemVC
      } else if let item = item as? RoastItem {
        guard let boastRoastVC = ProfileBoastRoastViewController
          .instantiate(boastRoastItem: item,
                       userName: userName,
                       style: .profile,
                       maxLines: self.maxLines) else {
                        print("Failed to create Boast Roast Item")
                        return
        }
        viewController = boastRoastVC
      } else if let item = item as? BoastItem {
        guard let boastRoastVC = ProfileBoastRoastViewController
          .instantiate(boastRoastItem: item,
                       userName: userName,
                       style: .profile,
                       maxLines: self.maxLines) else {
                        print("Failed to create Boast Roast Item")
                        return
        }
        viewController = boastRoastVC
      }
      guard let createdVC = viewController else {
        print("Failed to create View controller for content Item")
        continue
      }
      self.addChild(createdVC)
      createdVC.view.tag = count
      self.scrollContentView.addSubview(createdVC.view)
      self.scrollContentView.addConstraints([
        NSLayoutConstraint(item: createdVC.view as Any, attribute: .width, relatedBy: .equal,
                           toItem: self.scrollContentView, attribute: .width, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: createdVC.view as Any, attribute: .height, relatedBy: .equal,
                           toItem: self.scrollContentView, attribute: .height, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: createdVC.view as Any, attribute: .centerY, relatedBy: .equal,
                           toItem: self.scrollContentView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: createdVC.view as Any, attribute: .centerX, relatedBy: .equal,
                           toItem: self.scrollContentView, attribute: .centerX,
                           multiplier: (1.0 + CGFloat(0 * count)), constant: 0.0)
        ])
      count += 1
      createdVC.didMove(toParent: self)
      print("Added text item :\(count), \(item.content)")
    }
    
    print(self.scrollContentView.frame.size)
    self.pageControl.numberOfPages = count
  }
  
}

// MARK: - ScrollViewDelegate
extension ScrollableTextItemViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex: Int = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
    self.pageControl.currentPage = pageIndex
    let pagePercentage: CGFloat = scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.frame.width) / scrollView.frame.width
    if pageIndex < self.intrinsicContentHeights.count - 1 && pageIndex >= 0 {
      let newScrollViewHeight = self.intrinsicContentHeights[pageIndex] * (1 - pagePercentage) +
        self.intrinsicContentHeights[pageIndex + 1] * pagePercentage
      self.scrollViewHeightConstraint.constant = newScrollViewHeight + 20
      self.view.layoutIfNeeded()
    }
  }
}
