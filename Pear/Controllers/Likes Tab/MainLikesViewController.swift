//
//  MainLikesViewController.swift
//  Pear
//
//  Created by Avery Lamp on 6/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SDWebImage

extension Notification.Name {
  static let refreshLikesTab = Notification.Name("refreshLikesTab")
}

class MainLikesViewController: UIViewController {
  
  @IBOutlet weak var headerContainerView: UIView!
  
  enum MatchRequestState {
    case initalState
    case loading
    case noRequests
    case requestsAvailable
  }
  
  private var messageRefreshTimer: Timer = Timer()

  var requestsState: MatchRequestState = .initalState
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> MainLikesViewController? {
    guard let mainLikesVC = R.storyboard.mainLikesViewController
      .instantiateInitialViewController() else { return nil }
    return mainLikesVC
  }
}

// MARK: - Life Cycle
extension MainLikesViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("Main Likes VC Loaded")
    self.setup()
    self.stylize()
    self.refreshRequests()
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(MainLikesViewController.refreshRequests),
                                           name: .refreshLikesTab,
                                           object: nil)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if self.requestsState == .initalState || self.requestsState == .noRequests {
      self.refreshRequests()
    }
  }
  
  /// Setup should only be called once
  func setup() {
    
  }
  
  /// Stylize can be called more than once
  func stylize() {
    
  }

  @objc func refreshRequests() {
    guard self.requestsState != .loading else {
      return
    }
    self.requestsState = .loading
    self.displayLoadingAnimation()
    DataStore.shared.refreshMatchRequests { (matchRequests) in
      DispatchQueue.main.async {
        SlackHelper.shared.addEvent(uniquePrefix: "Match Requests Loaded: ", text: "\(matchRequests.count) found", color: matchRequests.count > 0 ? UIColor.green : UIColor.orange)
        print("Updating with \(matchRequests.count) match requests")
        if matchRequests.count > 0 {
          self.tabBarItem.badgeValue = "\(matchRequests.count)"
        } else {
          self.tabBarItem.badgeValue = nil
        }
        NotificationCenter.default.post(name: .updateAppIconNumber, object: nil)
        self.updateMatchRequestsToShow(matchRequests: DataStore.shared.matchRequests)
      }
    }
  }
  
  func updateMatchRequestsToShow(matchRequests: [Match]) {
    if DataStore.shared.matchRequests.count > 0 {
      var imagesToPrefetch: [URL] = []
      DataStore.shared.matchRequests.map({ $0.otherUser.displayedImages }).forEach({ $0.forEach {
        let imageString = $0.large.imageURL
        if let imageURL = URL(string: imageString) {
          imagesToPrefetch.append(imageURL)
        }
        }})
      SDWebImagePrefetcher.shared.prefetchURLs(imagesToPrefetch)
      self.requestsState = .requestsAvailable
      self.displayNextRequest()
    } else {
      self.requestsState = .noRequests
      self.displayNoRequests()
    }
  }
  
  func displayNextRequest() {
    if DataStore.shared.matchRequests.count > 0 {
      self.tabBarItem.badgeValue = "\(DataStore.shared.matchRequests.count)"
    } else {
      self.tabBarItem.badgeValue = nil
    }
    NotificationCenter.default.post(name: .updateAppIconNumber, object: nil)
    self.view.subviews.forEach({
      if $0 != self.headerContainerView {
        $0.removeFromSuperview()
      }
    })
    if let firstRequest = DataStore.shared.matchRequests.popLast(),
      let likeFullProfile = LikeFullProfileViewController.instantiate(match: firstRequest) {
      self.addChild(likeFullProfile)
      self.view.addSubview(likeFullProfile.view)
      likeFullProfile.view.translatesAutoresizingMaskIntoConstraints = false
      self.view.addConstraints([
        NSLayoutConstraint(item: likeFullProfile.view as Any, attribute: .top, relatedBy: .equal,
                           toItem: self.headerContainerView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: likeFullProfile.view as Any, attribute: .right, relatedBy: .equal,
                           toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: likeFullProfile.view as Any, attribute: .left, relatedBy: .equal,
                           toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: likeFullProfile.view as Any, attribute: .bottom, relatedBy: .equal,
                           toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        ])
      likeFullProfile.delegate = self
      likeFullProfile.didMove(toParent: self)
    } else {
      self.refreshRequests()
    }
  }
  
  func displayNoRequests() {
    self.view.subviews.forEach({
      if $0 != self.headerContainerView {
        $0.removeFromSuperview()
      }
    })
    let noRequestsLabel = UILabel()
    noRequestsLabel.translatesAutoresizingMaskIntoConstraints = false
    noRequestsLabel.textAlignment = .center
    noRequestsLabel.numberOfLines = 0
    noRequestsLabel.text = "You have no requests.\nCheck back later"
    noRequestsLabel.textColor = UIColor(white: 0.0, alpha: 0.3)
    if let font = R.font.openSansRegular(size: 18) {
      noRequestsLabel.font = font
    }
    self.view.addSubview(noRequestsLabel)
    self.view.addConstraints([
      NSLayoutConstraint(item: noRequestsLabel, attribute: .centerX, relatedBy: .equal,
                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: noRequestsLabel, attribute: .centerY, relatedBy: .equal,
                         toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: noRequestsLabel, attribute: .left, relatedBy: .equal,
                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: 40.0),
      NSLayoutConstraint(item: noRequestsLabel, attribute: .right, relatedBy: .equal,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: -40.0)
      ])
    
  }
 
  func displayLoadingAnimation() {
    self.view.subviews.forEach({
      if $0 != self.headerContainerView {
        $0.removeFromSuperview()
      }
    })
    let loadingLabel = UILabel()
    loadingLabel.translatesAutoresizingMaskIntoConstraints = false
    loadingLabel.numberOfLines = 0
    loadingLabel.textAlignment = .center
    if let font = R.font.openSansRegular(size: 18.0) {
      loadingLabel.font = font
    }
    loadingLabel.textColor = UIColor(white: 0.0, alpha: 0.3)
    loadingLabel.text = "Loading your match requests..."
    let loadingIndicator = UIActivityIndicatorView()
    loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    loadingIndicator.style = .whiteLarge
    loadingIndicator.startAnimating()
    loadingIndicator.color = UIColor(white: 0.0, alpha: 0.3)
    loadingIndicator.hidesWhenStopped = true
    self.view.addSubview(loadingLabel)
    self.view.addSubview(loadingIndicator)
    
    self.view.addConstraints([
      NSLayoutConstraint(item: loadingLabel, attribute: .centerX, relatedBy: .equal,
                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: loadingLabel, attribute: .centerY, relatedBy: .equal,
                         toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: loadingLabel, attribute: .left, relatedBy: .equal,
                         toItem: self.view, attribute: .left, multiplier: 1.0, constant: 40.0),
      NSLayoutConstraint(item: loadingLabel, attribute: .right, relatedBy: .equal,
                         toItem: self.view, attribute: .right, multiplier: 1.0, constant: -40.0),
      NSLayoutConstraint(item: loadingIndicator, attribute: .centerX, relatedBy: .equal,
                         toItem: loadingLabel, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: loadingIndicator, attribute: .bottom, relatedBy: .equal,
                         toItem: loadingLabel, attribute: .top, multiplier: 1.0, constant: -20.0)
      ])
    
  }
  
}

// MARK: - Like Full Profile Delegate
extension MainLikesViewController: LikeFullProfileDelegate {
  func decisionMade(accepted: Bool) {
    if accepted {
      SlackHelper.shared.addEvent(text: "Match Request Accepted!", color: UIColor.green)
    } else {
      SlackHelper.shared.addEvent(text: "Match Request Rejected!", color: UIColor.red)
    }
    DispatchQueue.main.async {
      self.displayNextRequest()
    }
  }
}
