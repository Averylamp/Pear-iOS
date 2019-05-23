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
  
  var user: PearUser!
  var infoItems: [InfoTableViewItem] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserBasicInfoTableViewController? {
    guard let userBasicInfoVC = R.storyboard.userBasicInfoTableViewController()
      .instantiateInitialViewController() as? UserBasicInfoTableViewController else {
        return nil
    }
    userBasicInfoVC.updateWithUser()
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
    infoItems.append(InfoTableViewItem(type: .name, subtitleText: name.count > 0 ? name : "Required",
                                       visibility: true, filledOut: !nameNeeded, requiredFilledOut: true))
    var ageText = user.age != nil ?  "\(user.age!) years old": "Required"
    if let birthday = DataStore.shared.currentPearUser?.birthdate, user.age != nil {
      let birthdayFormatter = DateFormatter()
      birthdayFormatter.timeZone = TimeZone(secondsFromGMT: 0)
      birthdayFormatter.dateFormat = "MM/dd/yyyy"
      ageText += ", \(birthdayFormatter.string(from: birthday))"
    }
    infoItems.append(InfoTableViewItem(type: .age, subtitleText: ageText,
                                       visibility: true, filledOut: user.age != nil, requiredFilledOut: true))
    infoItems.append(InfoTableViewItem(type: .gender, subtitleText: user.gender != nil ?  "\(user.gender!.toString())": "Required",
                                       visibility: true, filledOut: user.gender != nil, requiredFilledOut: true))

    var schoolString = user.school ?? "Optional"
    if let schoolYear = user.schoolYear, schoolString != "Optional" {
      schoolString += ", Class of \(schoolYear)"
    }
    infoItems.append(InfoTableViewItem(type: .school,
                                       subtitleText: schoolString, visibility: true, filledOut: schoolString != "Optional", requiredFilledOut: false))

    //    infoItems.append(InfoTableViewItem(titleText: "Height", subtitleText: user.age != nil ?  "\(user.age!)": "Required",
    //                                       visibility: true, filledOut: user.age != nil, requiredFilledOut: true))
    
    let ethnicityString = user.matchingDemographics.ethnicity.toOptionalString(mapFunction: { $0.toString()})
    infoItems.append(InfoTableViewItem(type: .ethnicity, subtitleText: ethnicityString  != nil ?  "\(ethnicityString!)": "Optional",
                                       visibility: false, filledOut: ethnicityString != nil, requiredFilledOut: false))
    
    return infoItems
  }
  
  func updateWithUser() {
    guard let user = DataStore.shared.currentPearUser else {
      print("Failed to find current user for basic info")
      return
    }
    self.user = user
    self.infoItems = UserBasicInfoTableViewController.getInfoItems(user: user)
  }
  
}

// MARK: - Life Cycle
extension UserBasicInfoTableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.updateWithUser()
    self.tableView.reloadData()
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
    cell.infoItemButton.tag = indexPath.row
    cell.infoItemButton.addTarget(self, action: #selector(UserBasicInfoTableViewController.tappedItemButton(sender:)), for: .touchUpInside)
    return cell
  }
  
  @objc func tappedItemButton(sender: UIButton) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if sender.tag <  self.infoItems.count {
      let infoItem = self.infoItems[sender.tag]
      self.tappedItemOfType(type: infoItem.type)
    }
  }
  
  func tappedItemOfType(type: UserInfoType) {
    switch type {
    case .name:
      guard let userNameInputVC = UserNameInputViewController.instantiate() else {
        print("Unable to instantiate User Name Input")
        return
      }
      self.navigationController?.pushViewController(userNameInputVC, animated: true)
    case .age:
      guard let userAgeInputVC = UserAgeInputViewController.instantiate() else {
        print("Unable to instantiate Age Input VC")
        return
      }
      self.navigationController?.pushViewController(userAgeInputVC, animated: true)
    case .gender:
      guard let userGenderInputVC = UserGenderInputViewController.instantiate() else {
        print("Unable to instantiate Gender Input VC")
        return
      }
      self.navigationController?.pushViewController(userGenderInputVC, animated: true)
    case .school:
      guard let userSchoolInputVC = UserSchoolInputViewController.instantiate() else {
        print("Unable to instantiate School Input VC")
        return
      }
      self.navigationController?.pushViewController(userSchoolInputVC, animated: true)
    case .ethnicity:
      guard let userEthnicityInputVC = UserEthnicityInputViewController.instantiate() else {
        print("Unable to instantiate Ethnicity Input VC")
        return
      }
      self.navigationController?.pushViewController(userEthnicityInputVC, animated: true)
    default:
      break
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let infoItem = self.infoItems[indexPath.row]
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.tappedItemOfType(type: infoItem.type)
  }
  
}
