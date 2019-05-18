//
//  UserBasicInfoViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserBasicInfoTableViewController: UIViewController {

  @IBOutlet var tableView: UITableView!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserBasicInfoTableViewController? {
    guard let userBasicInfoVC = R.storyboard.userBasicInfoTableViewController()
      .instantiateInitialViewController() as? UserBasicInfoTableViewController else {
        return nil
    }
    return userBasicInfoVC
  }
  
}

// MARK: - Life Cycle
extension UserBasicInfoTableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    
  }
  
  func setup() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
  }
  
}

// MARK: - UITableViewDelegate/DataSource
extension UserBasicInfoTableViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.infoItemTVC.identifier, for: indexPath) as? InfoItemTableViewCell else {
      print("Unable to dequeue cell")
      return UITableViewCell()
    }
    
    return cell
  }
  
}
