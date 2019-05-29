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
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
  
  var items: [TextContentItem] = []
  var intrinsicContentHeights: [CGFloat] = []
  var userName: String?
  var maxLines: Int = 0
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(items: [TextContentItem], userName: String? = nil, maxLines: Int = 0) -> ScrollableTextItemViewController? {
    guard let scrollingItemVC = R.storyboard.scrollableTextItemViewController
      .instantiateInitialViewController()  else { return nil }
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
      var viewController: UITextViewItemViewController?
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
      self.stackView.addArrangedSubview(createdVC.view)
      self.scrollView.addConstraints([
        NSLayoutConstraint(item: createdVC.view as Any, attribute: .width, relatedBy: .equal,
                           toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: createdVC.view as Any, attribute: .height, relatedBy: .equal,
                           toItem: self.scrollView, attribute: .height, multiplier: 1.0, constant: 0.0)
        ])
      count += 1
      createdVC.didMove(toParent: self)
      print("Added text item \(count), \(item.content)")
      self.view.layoutIfNeeded()
      self.intrinsicContentHeights.append(createdVC.intrinsicHeight())
    }
    self.pageControl.numberOfPages = count
    if let firstIntrinsicHeight = self.intrinsicContentHeights.first {
      self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * CGFloat(count), height: firstIntrinsicHeight)
    }
    self.view.layoutIfNeeded()
    self.updateScrollViewHeight()
  }
  
}

// MARK: - ScrollViewDelegate
extension ScrollableTextItemViewController: UIScrollViewDelegate {
  
  func updateScrollViewHeight() {
    let pageIndex: Int = Int(floor(self.scrollView.contentOffset.x / self.scrollView.frame.width))
    self.pageControl.currentPage = pageIndex
    let pagePercentage: CGFloat = self.scrollView.contentOffset.x.truncatingRemainder(dividingBy: self.scrollView.frame.width) / self.scrollView.frame.width
    if pageIndex < self.intrinsicContentHeights.count - 1 && pageIndex >= 0 {
      let newScrollViewHeight = self.intrinsicContentHeights[pageIndex] * (1 - pagePercentage) +
        self.intrinsicContentHeights[pageIndex + 1] * pagePercentage
      self.scrollViewHeightConstraint.constant = newScrollViewHeight
      self.view.layoutIfNeeded()
    } else if  pageIndex < self.intrinsicContentHeights.count && pageIndex >= 0 {
      self.scrollViewHeightConstraint.constant = self.intrinsicContentHeights[pageIndex]
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.updateScrollViewHeight()
  }
  
}
