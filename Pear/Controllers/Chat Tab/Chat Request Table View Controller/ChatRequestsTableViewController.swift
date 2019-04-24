//
//  ChatRequestsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

enum ChatRequestTableViewType: Int {
  case inbox = 0
  case requests = 1
}

protocol ChatRequestTableViewControllerDelegate: class {
  
  func selectedMatch(match: Match)
  func selectedProfile(user: PearUser)
  
}

class ChatRequestsTableViewController: UIViewController {
  
  var requests: [Match] = []
  var requestTableViewType: ChatRequestTableViewType!
  weak var delegate: ChatRequestTableViewControllerDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var noRequestsImage: UIImageView!
  @IBOutlet weak var noRequestsContainer: UIView!
  @IBOutlet weak var noRequestsText: UILabel!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(tableViewType: ChatRequestTableViewType) -> ChatRequestsTableViewController? {
    let storyboard = UIStoryboard(name: String(describing: ChatRequestsTableViewController.self), bundle: nil)
    guard let chatMainVC = storyboard.instantiateInitialViewController() as? ChatRequestsTableViewController else { return nil }
    chatMainVC.requestTableViewType = tableViewType
    return chatMainVC
  }
  
}

// MARK: - Life Cycle
extension ChatRequestsTableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    self.tableView.separatorStyle = .none
    self.tableView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
    if let font = R.font.openSansRegular(size: 18) {
      self.noRequestsText.font = font
    }
    self.noRequestsText.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
  }
  
  func setup() {
    self.tableView.dataSource = self
    self.tableView.delegate = self
    if self.requestTableViewType == .inbox {
      noRequestsImage.image = R.image.noMatchesIcon()
      noRequestsText.text = "You have no chats.\nGo wave to some people!"
    } else if self.requestTableViewType == .requests {
      noRequestsImage.image = R.image.noRequestsIcon()
      noRequestsText.text = "You have no requests.\nCheck back later!"
    }
  }
  
  func updateMatches(matches: [Match]) {
    self.requests = matches
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
  
}

// MARK: - UITableViewDelegate/DataSource
extension ChatRequestsTableViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if requests.count > 0 {
      self.noRequestsContainer.isHidden = true
    }
    return requests.count
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let delegate = delegate {
      delegate.selectedMatch(match: self.requests[indexPath.row])
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRequestItemTVC", for: indexPath) as? ChatRequestsTableViewCell else {
      print("Failed to instantiate Chat Request TVC")
      return UITableViewCell()
    }
    cell.backgroundColor = nil
    cell.selectionStyle = .none
    let match = self.requests[indexPath.row]
    cell.configure(match: match, index: indexPath.row)
    cell.delegate = self
    return cell
  }
  
}

// MARK: - UITableViewCellDelegate
extension ChatRequestsTableViewController: ChatRequestsTableViewCellDelegate {
  
  func didSelectThumbnailAtIndex(index: Int) {
    if let delegate = self.delegate {
      delegate.selectedProfile(user: self.requests[index].otherUser)
    }
  }
  
}
