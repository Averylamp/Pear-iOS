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
    guard let userMoreDetailsVC = R.storyboard.userMoreDetailsTableViewController
      .instantiateInitialViewController()  else {
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
    infoItems.append(user.matchingDemographics.cannabis.toInfoItem(type: .cannabis, mapFunction: { $0.toString() }))
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
    cell.infoItemButton.tag = indexPath.row
    cell.infoItemButton.addTarget(self, action: #selector(UserMoreDetailsTableViewController.tappedItemButton(sender:)), for: .touchUpInside)
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
    case .political:
      guard let politicalViewsVC = UserPoliticalViewsInputViewController.instantiate() else {
        print("Unable to instantiate Political Views Input")
        return
      }
      self.navigationController?.pushViewController(politicalViewsVC, animated: true)
    case .religion:
      guard let userReligionVC = UserReligionInputViewController.instantiate() else {
        print("Unable to instantiate Religion Input VC")
        return
      }
      self.navigationController?.pushViewController(userReligionVC, animated: true)
    case .education:
      guard let userEducationLevelVC = UserEducationLevelInputViewController.instantiate() else {
        print("Unable to instantiate Education Level Input VC")
        return
      }
      self.navigationController?.pushViewController(userEducationLevelVC, animated: true)
    case .drinking:
      guard let userHabitInputVC = UserHabitsInputViewController.instantiate(habitType: .drinking) else {
        print("Unable to instantiate Habit Drinking VC")
        return
      }
      self.navigationController?.pushViewController(userHabitInputVC, animated: true)
    case .smoking:
      guard let userHabitInputVC = UserHabitsInputViewController.instantiate(habitType: .smoking) else {
        print("Unable to instantiate Habit Smoking VC")
        return
      }
      self.navigationController?.pushViewController(userHabitInputVC, animated: true)
    case .cannabis:
      guard let userHabitInputVC = UserHabitsInputViewController.instantiate(habitType: .cannabis) else {
        print("Unable to instantiate Habit Cannabis VC")
        return
      }
      self.navigationController?.pushViewController(userHabitInputVC, animated: true)
    case .drugs:
      guard let userHabitInputVC = UserHabitsInputViewController.instantiate(habitType: .drugs) else {
        print("Unable to instantiate Habit Drugs VC")
        return
      }
      self.navigationController?.pushViewController(userHabitInputVC, animated: true)
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
