//
//  UserBasicInfoViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

enum BasicInfoType {
  case name
  case age
  case gender
  case height
  case ethnicity
  case school
  case work
  case jobTitle
}

struct InfoTableViewItem {
  let titleText: String
  let subtitleText: String
  let visibility: Bool
  let filledOut: Bool
  let requiredFilledOut: Bool
}

class UserBasicInfoTableViewController: UIViewController {

  @IBOutlet var tableView: UITableView!
  
  var user: PearUser!
  var infoItems: [InfoTableViewItem] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(user: PearUser) -> UserBasicInfoTableViewController? {
    guard let userBasicInfoVC = R.storyboard.userBasicInfoTableViewController()
      .instantiateInitialViewController() as? UserBasicInfoTableViewController else {
        return nil
    }
    userBasicInfoVC.user = user
    userBasicInfoVC.infoItems = UserBasicInfoTableViewController.getInfoItems(user: user)
    return userBasicInfoVC
  }
  
  static func getInfoItems(user: PearUser) -> [InfoTableViewItem] {
    var infoItems: [InfoTableViewItem] = []
    var name: String = ""
    if let firstName = user.firstName {
      name += firstName
    }
    if let lastName = user.lastName {
      if name.count > 0 {
        name += " "
      }
      name += lastName
    }
    var nameNeeded: Bool = false
    if user.firstName == nil || user.lastName == nil {
      nameNeeded = true
    }
    infoItems.append(InfoTableViewItem(titleText: "Name", subtitleText: name.count > 0 ? name : "Required",
                                       visibility: true, filledOut: !nameNeeded, requiredFilledOut: true))
    infoItems.append(InfoTableViewItem(titleText: "Age", subtitleText: user.age != nil ?  "\(user.age!)": "Required",
                                       visibility: true, filledOut: user.age != nil, requiredFilledOut: true))
    infoItems.append(InfoTableViewItem(titleText: "Gender", subtitleText: user.gender != nil ?  "\(user.gender!.toString())": "Required",
                                       visibility: true, filledOut: user.gender != nil, requiredFilledOut: true))
//    infoItems.append(InfoTableViewItem(titleText: "Height", subtitleText: user.age != nil ?  "\(user.age!)": "Required",
//                                       visibility: true, filledOut: user.age != nil, requiredFilledOut: true))
    let ethnicityString = user.matchingDemographics.ethnicity.toOptionalString(mapFunction: { $0.toString()})
    infoItems.append(InfoTableViewItem(titleText: "Ethnicity", subtitleText: ethnicityString  != nil ?  "\(ethnicityString!)": "Optional",
                                       visibility: false, filledOut: ethnicityString != nil, requiredFilledOut: false))
    
    return infoItems
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
