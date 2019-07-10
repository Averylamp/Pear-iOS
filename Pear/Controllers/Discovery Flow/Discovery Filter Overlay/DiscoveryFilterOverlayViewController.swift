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
  
  struct DiscoveryFilterItem {
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
  let filterItemsTableView = UITableView()
  static let cardSideOffset: CGFloat = 30.0
  static let filterItemHeight: CGFloat = 36.0
  static let discoveryFilterItemCellIdentifier: String = "DiscoveryFilterItemTVC"
  
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
      let newHeight = presenting ? CGFloat(self.filterItems.count + 1) * DiscoveryFilterOverlayViewController.filterItemHeight : 0.0
      if let heightConstraint = self.filterCardViewHeightConstraint {
        heightConstraint.constant = newHeight
      }
      UIView.animate(withDuration: 0.4, animations: {
        self.view.layoutIfNeeded()
      }, completion: { (_) in
        if let completion = completion {
          completion()
        }
      })
    }
  }
  
  static func generateDiscoveryFilterItems() -> [DiscoveryFilterItem] {
    var items: [DiscoveryFilterItem] = []
    let selectedFilterID = DataStore.shared.getCurrentFilters().userID
    if let currentPearUser = DataStore.shared.currentPearUser,
      let thumbnailURLString =  currentPearUser.displayedImages.first?.thumbnail.imageURL,
      let thumbnailURL = URL(string: thumbnailURLString) {
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
    self.filterCardView.backgroundColor = UIColor.white
    self.filterCardView.layer.cornerRadius = 12.0
    self.filterCardView.layer.shadowRadius = 8
    self.filterCardView.layer.shadowOpacity = 0.15
    self.filterCardView.clipsToBounds = true
    self.filterCardView.layer.shadowOffset = CGSize(width: 1, height: 1)
    self.filterCardView.layer.shadowColor = UIColor(white: 0.0, alpha: 0.0).cgColor
    self.filterCardView.translatesAutoresizingMaskIntoConstraints = false
    self.filterCardViewHeightConstraint = NSLayoutConstraint(item: self.filterCardView, attribute: .height, relatedBy: .equal,
                                                             toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
    self.filterCardViewHeightConstraint?.priority = .defaultHigh
    self.view.addConstraints([
      self.filterCardViewHeightConstraint!,
      NSLayoutConstraint(item: self.filterCardView, attribute: .left, relatedBy: .equal,
                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: DiscoveryFilterOverlayViewController.cardSideOffset),
      NSLayoutConstraint(item: self.filterCardView, attribute: .right, relatedBy: .equal,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: -DiscoveryFilterOverlayViewController.cardSideOffset),
      NSLayoutConstraint(item: self.filterCardView, attribute: .top, relatedBy: .equal,
                         toItem: self.view, attribute: .top, multiplier: 1.0, constant: self.topOffset),
      NSLayoutConstraint(item: self.filterCardView, attribute: .bottom, relatedBy: .lessThanOrEqual,
                         toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -40.0)
      ])
    
    self.filterItemsTableView.translatesAutoresizingMaskIntoConstraints = false
    self.filterItemsTableView.register(DiscoveryFilterItemTableViewCell.self,
                                       forCellReuseIdentifier: DiscoveryFilterOverlayViewController.discoveryFilterItemCellIdentifier)
    self.filterItemsTableView.delegate = self
    self.filterItemsTableView.dataSource = self
    self.filterCardView.addSubview(self.filterItemsTableView)
    self.filterCardView.addConstraints([
      NSLayoutConstraint(item: self.filterItemsTableView, attribute: .centerX, relatedBy: .equal,
                         toItem: self.filterCardView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.filterItemsTableView, attribute: .width, relatedBy: .equal,
                         toItem: self.filterCardView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.filterItemsTableView, attribute: .top, relatedBy: .equal,
                         toItem: self.filterCardView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.filterItemsTableView, attribute: .bottom, relatedBy: .equal,
                         toItem: self.filterCardView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      ])
    
  }
  
  /// Stylize can be called more than once
  func stylize() {
    self.overlayButton.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
  }
  
}

// MARK: - UITableViewDelegate/DataSource
extension DiscoveryFilterOverlayViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.filterItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: DiscoveryFilterOverlayViewController.discoveryFilterItemCellIdentifier,
                                                   for: indexPath) as? DiscoveryFilterItemTableViewCell else {
      print("Unable to dequeue DFITVCs")
      return UITableViewCell()
    }
    
    return cell
  }
  
}
