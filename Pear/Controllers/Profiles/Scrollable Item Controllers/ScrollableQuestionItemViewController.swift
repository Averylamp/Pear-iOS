//
//  ScrollableQuestionItemViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ScrollableQuestionItemViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
  
  var items: [QuestionResponseItem] = []
  var intrinsicContentHeights: [CGFloat] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(items: [QuestionResponseItem]) -> ScrollableQuestionItemViewController? {
    guard let scrollingItemVC = R.storyboard.scrollableQuestionItemViewController()
      .instantiateInitialViewController() as? ScrollableQuestionItemViewController else { return nil }
    scrollingItemVC.items = items
    return scrollingItemVC
  }
  
}

extension ScrollableQuestionItemViewController {
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
      
      guard let questionResponseVC = ProfileQuestionResponseViewController.instantiate(questionItem: item) else {
        print("Unable to instantiate question response item VC")
        continue
      }
      self.addChild(questionResponseVC)
      questionResponseVC.view.tag = count
      self.stackView.addArrangedSubview(questionResponseVC.view)
      self.scrollView.addConstraints([
        NSLayoutConstraint(item: questionResponseVC.view as Any, attribute: .width, relatedBy: .equal,
                           toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: questionResponseVC.view as Any, attribute: .height, relatedBy: .equal,
                           toItem: self.scrollView, attribute: .height, multiplier: 1.0, constant: 0.0)
        ])
      count += 1
      questionResponseVC.didMove(toParent: self)
      print("Added text item \(count), \(item.question)")
      self.view.layoutIfNeeded()
      self.intrinsicContentHeights.append(questionResponseVC.intrinsicHeight())
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
extension ScrollableQuestionItemViewController: UIScrollViewDelegate {
  
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
