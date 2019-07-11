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
    let documentID: String
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
  static let filterItemHeight: CGFloat = 60.0
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
  
  @objc func addFriendClicked(sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    
  }
  
  func animateFilterPopup(presenting: Bool, completion: (() -> Void)? = nil) {
    DispatchQueue.main.async {
//      let newHeight = presenting ? CGFloat(self.filterItems.count + 1) * DiscoveryFilterOverlayViewController.filterItemHeight : 0.0
      let newHeight = presenting ? CGFloat(self.filterItems.count) * DiscoveryFilterOverlayViewController.filterItemHeight : 0.0
      if let heightConstraint = self.filterCardViewHeightConstraint {
        heightConstraint.constant = newHeight
      }
      UIView.animate(withDuration: 0.4, animations: {
        self.view.layoutIfNeeded()
        self.filterCardView.alpha = presenting ? 1.0 : 0.0
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
                                       firstName: "You",
                                       documentID: currentPearUser.documentID,
                                       selected: currentPearUser.documentID == selectedFilterID))
    }
    DataStore.shared.endorsedUsers.forEach({
      if let thumbnailURLString = $0.displayedImages.first?.thumbnail.imageURL,
        let thumbnailURL = URL(string: thumbnailURLString) {
        items.append(DiscoveryFilterItem(thumbnailURL: thumbnailURL,
                                         firstName: $0.firstName ?? "No name",
                                         documentID: $0.documentID,
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
    self.filterItemsTableView.reloadData()
  }
  
  /// Setup should only be called once
  func setup() {
    
    self.view.addSubview(self.filterCardView)
    self.filterCardView.alpha = 0.0
    self.filterCardView.backgroundColor = UIColor.white
    self.filterCardView.layer.cornerRadius = 12.0
    self.filterCardView.layer.shadowRadius = 8
    self.filterCardView.layer.shadowOpacity = 0.25
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
    self.filterItemsTableView.estimatedRowHeight = DiscoveryFilterOverlayViewController.filterItemHeight
    self.filterItemsTableView.register(DiscoveryFilterItemTableViewCell.self,
                                       forCellReuseIdentifier: DiscoveryFilterOverlayViewController.discoveryFilterItemCellIdentifier)
    self.filterItemsTableView.delegate = self
    self.filterItemsTableView.dataSource = self
    self.filterItemsTableView.separatorStyle = .none
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
    
    self.view.layoutIfNeeded()
  }
  
  func getTableFooterView() -> UIView {
    let containerView = UIButton()
    containerView.addTarget(self,
                            action: #selector(DiscoveryFilterOverlayViewController.addFriendClicked(sender:)),
                            for: .touchUpInside)
    
    // Plus Icon Image View
    let plusImageView = UIImageView()
    plusImageView.translatesAutoresizingMaskIntoConstraints = false
    plusImageView.contentMode = .scaleAspectFill
    plusImageView.image = R.image.discoveryFilterIconPlus()
    containerView.addSubview(plusImageView)
    containerView.addConstraints([
     NSLayoutConstraint(item: plusImageView, attribute: .width, relatedBy: .equal,
                        toItem: plusImageView, attribute: .height, multiplier: 1.0, constant: 0.0),
     NSLayoutConstraint(item: plusImageView, attribute: .height, relatedBy: .equal,
                        toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 38.0),
     NSLayoutConstraint(item: plusImageView, attribute: .centerY, relatedBy: .equal,
                        toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
     NSLayoutConstraint(item: plusImageView, attribute: .left, relatedBy: .equal,
                        toItem: containerView, attribute: .left, multiplier: 1.0, constant: 12.0)
    ])
    
    // Add Friends Label
    let addFriendLabel = UILabel()
    addFriendLabel.translatesAutoresizingMaskIntoConstraints = false
    addFriendLabel.text = "ADD A FRIEND"
    addFriendLabel.textColor = UIColor(red: 0.22, green: 0.81, blue: 0.45, alpha: 1.00)
    if let font = R.font.openSansExtraBold(size: 16) {
      addFriendLabel.font = font
    }
    containerView.addSubview(addFriendLabel)
    containerView.addConstraints([
      NSLayoutConstraint(item: addFriendLabel, attribute: .left, relatedBy: .equal,
                         toItem: plusImageView, attribute: .right, multiplier: 1.0, constant: 12.0),
      NSLayoutConstraint(item: addFriendLabel, attribute: .centerY, relatedBy: .equal,
                         toItem: plusImageView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: addFriendLabel, attribute: .right, relatedBy: .equal,
                         toItem: containerView, attribute: .right, multiplier: 1.0, constant: -12.0)
     ])

    // Separator
    let seperatorView = UIView()
    seperatorView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(seperatorView)
    containerView.addConstraints([
      NSLayoutConstraint(item: seperatorView, attribute: .centerX, relatedBy: .equal,
                         toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: seperatorView, attribute: .width, relatedBy: .equal,
                         toItem: containerView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: seperatorView, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0),
      NSLayoutConstraint(item: seperatorView, attribute: .top, relatedBy: .equal,
                         toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0)
      ])
    seperatorView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)

    containerView.backgroundColor = UIColor.white
    return containerView
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
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return DiscoveryFilterOverlayViewController.filterItemHeight
  }
  
//  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//    return self.getTableFooterView()
//  }
//
//  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//    return DiscoveryFilterOverlayViewController.filterItemHeight
//  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: DiscoveryFilterOverlayViewController.discoveryFilterItemCellIdentifier,
                                                   for: indexPath) as? DiscoveryFilterItemTableViewCell else {
      print("Unable to dequeue DFITVCs")
      return UITableViewCell()
    }
    self.view.layoutIfNeeded()
    let item = self.filterItems[indexPath.row]
    cell.stylize(url: item.thumbnailURL,
                 firstName: item.firstName,
                 selected: item.selected)
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedItem = self.filterItems[indexPath.row]
    if !selectedItem.selected {
      
    }
  }
  
}
