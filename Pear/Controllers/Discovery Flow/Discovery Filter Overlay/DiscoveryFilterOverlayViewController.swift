//
//  DiscoveryFilterOverlayViewController.swift
//  Pear
//
//  Created by Avery Lamp on 7/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SDWebImage

protocol DiscoveryFilterOverlayDelegate: class {
  func dismissFilterOverlay()
}

class DiscoveryFilterOverlayViewController: UIViewController {
  
  struct DiscoveryFilterItem{
    let thumbnailURL: URL
    let firstName: String
    var selected: Bool
  }
  
  weak var delegate: DiscoveryFilterOverlayDelegate?
  
  @IBOutlet var overlayButton: UIButton!
  
  var filterItems: [DiscoveryFilterItem] = []
  var topOffset: CGFloat = 100.0
  var isDismissing: Bool = false
  let filterCardView: UIView = UIView()
  var filterCardViewHeightConstraint: NSLayoutConstraint?
  static let cardSideOffset: CGFloat = 30.0
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(topOffset: CGFloat) -> DiscoveryFilterOverlayViewController? {
    guard let filterOverlayVC = R.storyboard.discoveryFilterOverlayViewController
      .instantiateInitialViewController() else { return nil }
    filterOverlayVC.topOffset = topOffset
    filterOverlayVC.filterItems = DiscoveryFilterOverlayViewController.generateDiscoveryFilterItems()
    let prefetchURLs = filterOverlayVC.filterItems.map({ $0.thumbnailURL })
    SDWebImagePrefetcher.shared.prefetchURLs(prefetchURLs)
    return filterOverlayVC
  }
  
  @IBAction func overlayButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if let delegate = self.delegate {
      guard self.isDismissing == false else {
        return
      }
      self.isDismissing = true
      self.animateFilterPopup(presenting: false) {
        delegate.dismissFilterOverlay()
      }
    }
  }
  
  func animateFilterPopup(presenting: Bool, completion: (() -> Void)? = nil) {
    DispatchQueue.main.async {
      if presenting {
        
        if let completion = completion {
          completion()
        }
      } else {
        if let completion = completion {
          completion()
        }
      }      
    }
  }
  
  static func generateDiscoveryFilterItems() -> [DiscoveryFilterItem] {
    var items: [DiscoveryFilterItem] = []
    let selectedFilterID = DataStore.shared.getCurrentFilters().userID
    if let currentPearUser = DataStore.shared.currentPearUser,
      let thumbnailURLString =  currentPearUser.displayedImages.first?.thumbnail.imageURL,
      let thumbnailURL = URL(string: thumbnailURLString){
      items.append(DiscoveryFilterItem(thumbnailURL: thumbnailURL,
                                       firstName: currentPearUser.firstName ?? "No Name",
                                       selected: currentPearUser.documentID == selectedFilterID))
    }
    DataStore.shared.endorsedUsers.forEach({
      if let thumbnailURLString = $0.displayedImages.first?.thumbnail.imageURL,
        let thumbnailURL = URL(string: thumbnailURLString) {
        items.append(DiscoveryFilterItem(thumbnailURL: thumbnailURL,
                                         firstName: $0.firstName ?? "No name",
                                         selected: $0.documentID == selectedFilterID))
      }
    })
    return items
  }
  
}

// MARK: - Life Cycle
extension DiscoveryFilterOverlayViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  /// Setup should only be called once
  func setup() {
    self.view.addSubview(self.filterCardView)
    self.filterCardView.translatesAutoresizingMaskIntoConstraints = false
    self.filterCardViewHeightConstraint = NSLayoutConstraint(item: self.filterCardView, attribute: .height, relatedBy: .equal,
                                                             toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
    self.view.addConstraints([
      self.filterCardViewHeightConstraint!,
      NSLayoutConstraint(item: self.filterCardView, attribute: .left, relatedBy: .equal,
                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: DiscoveryFilterOverlayViewController.cardSideOffset),
      NSLayoutConstraint(item: self.filterCardView, attribute: .right, relatedBy: .equal,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: -DiscoveryFilterOverlayViewController.cardSideOffset),
      NSLayoutConstraint(item: self.filterCardView, attribute: .top, relatedBy: .equal,
                         toItem: self.view, attribute: .top, multiplier: 1.0, constant: self.topOffset)
      ])
    
  }
  
  /// Stylize can be called more than once
  func stylize() {
    
  }
  
}
