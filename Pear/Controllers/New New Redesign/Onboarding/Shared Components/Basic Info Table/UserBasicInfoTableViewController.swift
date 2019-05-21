//
//  UserBasicInfoViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

enum UserInfoType {
  case name
  case age
  case gender
  case height
  case ethnicity
  case school
  case work
  case jobTitle
  case hometown
  case education
  case religion
  case political
  case drinking
  case smoking
  case cannabis
  case drugs
  
  func toTitleString() -> String {
    switch self {
    case .name:
      return "Name"
    case .age:
      return "Age"
    case .gender:
      return "Gender"
    case .height:
      return "Height"
    case .ethnicity:
      return "Ethnicity"
    case .school:
      return "School"
    case .work:
      return "Work"
    case .jobTitle:
      return "Job Title"
    case .hometown:
      return "Hometown"
    case .education:
      return "Education Level"
    case .religion:
      return "Religion & Spirituality"
    case .political:
      return "Political Views"
    case .drinking:
      return "Drinking"
    case .smoking:
      return "Smoking"
    case .cannabis:
      return "Cannabis"
    case .drugs:
      return "Drugs"
    }
  }
  
  func defaultVisibility() -> Bool {
    switch self {
    case .name, .age, .gender, .school, .work, .jobTitle, .hometown:
      return true
    case .height, .ethnicity, .education, .religion, .political, .drinking, .smoking, .cannabis, .drugs:
      return false
    }
  }
  
  func requiredItem() -> Bool {
    switch self {
    case .name, .age, .gender:
      return true
    case .height, .ethnicity, .school, .work, .jobTitle, .hometown, .education,
         .religion, .political, .drinking, .smoking, .cannabis, .drugs:
      return false
    }
  }
  
}

struct InfoTableViewItem {
  let type: UserInfoType
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
    print("Appearing")
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
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let infoItem = self.infoItems[indexPath.row]
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    switch infoItem.type {
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
    default:
      break
    }
    
  }
  
}
