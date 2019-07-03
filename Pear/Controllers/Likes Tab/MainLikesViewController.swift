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

  var requestsToShow: [Match] = []
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
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  /// Setup should only be called once
  func setup() {
    
  }
  
  /// Stylize can be called more than once
  func stylize() {
    
  }

  func refreshRequests() {
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
        self.updateMatchRequestsToShow(matchRequests: matchRequests)
      }
    }
  }
  
  func updateMatchRequestsToShow(matchRequests: [Match]) {
    self.requestsToShow = matchRequests
    if self.requestsToShow.count > 0 {
      var imagesToPrefetch: [URL] = []
      self.requestsToShow.map({ $0.otherUser.displayedImages }).forEach({ $0.forEach {
        let imageString = $0.large.imageURL
        if let imageURL = URL(string: imageString) {
          imagesToPrefetch.append(imageURL)
        }
        }})
      SDWebImagePrefetcher.shared.prefetchURLs(imagesToPrefetch)

      self.requestsState = .requestsAvailable
    } else {
      self.requestsState = .noRequests
    }
  }
  
  func displayNoRequests() {
    
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
    loadingLabel.textColor = R.color.primaryTextColor()
    loadingLabel.text = "Loading your match requests..."
    let loadingIndicator = UIActivityIndicatorView()
    loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    loadingIndicator.style = .whiteLarge
    loadingIndicator.startAnimating()
    loadingIndicator.color = R.color.primaryTextColor()
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
