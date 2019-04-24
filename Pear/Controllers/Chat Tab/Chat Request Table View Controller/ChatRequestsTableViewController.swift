//
//  ChatRequestsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

protocol ChatRequestTableViewControllerDelegate: class {
  
  func selectedMatch(match: Match)
  func selectedProfile(user: PearUser)
  
}

class ChatRequestsTableViewController: UIViewController {
  
  var requests: [Match] = []
  weak var delegate: ChatRequestTableViewControllerDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> ChatRequestsTableViewController? {
    let storyboard = UIStoryboard(name: String(describing: ChatRequestsTableViewController.self), bundle: nil)
    guard let chatMainVC = storyboard.instantiateInitialViewController() as? ChatRequestsTableViewController else { return nil }
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
  }
  
  func setup() {
    self.tableView.dataSource = self
    self.tableView.delegate = self
    
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
