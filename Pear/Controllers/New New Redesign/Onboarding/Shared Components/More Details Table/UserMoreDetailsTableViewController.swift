//
//  UserMoreDetailsTableViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserMoreDetailsTableViewController: UIViewController {

  @IBOutlet var tableView: UITableView!
  
  var user: PearUser!
  var infoItems: [InfoTableViewItem] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserMoreDetailsTableViewController? {
    guard let userMoreDetailsVC = R.storyboard.userMoreDetailsTableViewController()
      .instantiateInitialViewController() as? UserMoreDetailsTableViewController else {
        return nil
    }
    userMoreDetailsVC.updateWithUser()
    return userMoreDetailsVC
  }
  
  static func getInfoItems(user: PearUser) -> [InfoTableViewItem] {
    var infoItems: [InfoTableViewItem] = []
    infoItems.append(user.matchingDemographics.educationLevel.toInfoItem(type: .education, mapFunction: { $0.toString() }))
    infoItems.append(user.matchingDemographics.religion.toInfoItem(type: .religion, mapFunction: { $0.toString() }))
    infoItems.append(user.matchingDemographics.politicalView.toInfoItem(type: .political, mapFunction: { $0.toString() }))
    infoItems.append(user.matchingDemographics.drinking.toInfoItem(type: .drinking, mapFunction: { $0.toString() }))
    infoItems.append(user.matchingDemographics.smoking.toInfoItem(type: .smoking, mapFunction: { $0.toString() }))
    infoItems.append(user.matchingDemographics.educationLevel.toInfoItem(type: .cannabis, mapFunction: { $0.toString() }))
    infoItems.append(user.matchingDemographics.drugs.toInfoItem(type: .drugs, mapFunction: { $0.toString() }))
    return infoItems
  }
  
  func updateWithUser() {
    guard let user = DataStore.shared.currentPearUser else {
      print("Failed to find current user for more info")
      return
    }
    self.user = user
    self.infoItems = UserMoreDetailsTableViewController.getInfoItems(user: user)
  }
  
}

// MARK: - Life Cycle
extension UserMoreDetailsTableViewController {
  
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
extension UserMoreDetailsTableViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.infoItems.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.infoItemTVC.identifier, for: indexPath) as? InfoItemTableViewCell else {
      print("Unable to dequeue cell")
      return UITableViewCell()
    }
    let item = infoItems[indexPath.row]
    cell.stylize(item: item)
    return cell
  }
  
}
