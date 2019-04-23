//
//  UserContactPermissionsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import Contacts

class UserContactPermissionsViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var numberProfilesLabel: UILabel!
  @IBOutlet weak var enableContactsButton: UIButton!
  @IBOutlet weak var tableViewContainerView: UIView!
  @IBOutlet weak var tableView: UITableView!
  
  var allSampleBoastRoastItems: [LatestRoastBoastItem] = []
  var currentBoastRoastItems: [LatestRoastBoastItem] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserContactPermissionsViewController? {
    guard let contactPermissionsVC = R.storyboard.userContactPermissionsViewController()
      .instantiateInitialViewController() as? UserContactPermissionsViewController else { return nil }
    return contactPermissionsVC
  }
  
  @IBAction func enableContactsButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
//    let predicate = CNContact.predicateForContacts(withIdentifiers: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey])
    let keysToFetch: [CNKeyDescriptor] = [CNContactGivenNameKey as CNKeyDescriptor,
                                         CNContactFamilyNameKey as CNKeyDescriptor,
                                         CNContactPhoneNumbersKey as CNKeyDescriptor]
    let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
    let store = CNContactStore()
    var allContacts: [CNContact] = []
    do {
      try store.enumerateContacts(with: fetchRequest) { (contact, _) in
        if contact.phoneNumbers.count > 0 {
          allContacts.append(contact)
        }
      }
      print("\(allContacts.count) Contacts fetched")
      guard let contactListVC = UserContactListViewController.instantiate(contacts: allContacts) else {
        print("Failed to create Contact List VC")
        return
      }
      self.navigationController?.pushViewController(contactListVC, animated: true)
    } catch {
      print("Failed to fetch contacts: \(error)")
    }
    
  }
  
}

// MARK: - Life Cycle
extension UserContactPermissionsViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.loadSampleBoastRoasts()
  }
  
  func stylize() {
    self.view.backgroundColor = R.color.backgroundColorBlue()
    if let font = R.font.openSansExtraBold(size: 16) {
      self.titleLabel.font = font
    }
    
    self.titleLabel.textColor = UIColor.white
    if let font = R.font.openSansSemiBold(size: 16) {
      self.numberProfilesLabel.font = font
    }
    self.numberProfilesLabel.textColor = UIColor.white
    self.numberProfilesLabel.text = "No one has peared you yet 😢.  Pear a friend!"
    
    if let font = R.font.openSansBold(size: 18) {
      self.enableContactsButton.titleLabel?.font = font
    }
    self.enableContactsButton.setTitleColor(UIColor.black, for: .normal)
    self.enableContactsButton.backgroundColor = R.color.backgroundColorYellow()
    self.enableContactsButton.layer.cornerRadius = self.enableContactsButton.frame.height / 2.0
    
    self.tableViewContainerView.layer.cornerRadius = 12
    self.tableViewContainerView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
    self.tableView.backgroundColor = nil
    self.tableView.separatorStyle = .none
  }
  
  func setup() {
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.startRunLoop()
  }
  
  func startRunLoop() {
    _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
      let random = Int.random(in: 0..<6)
      self.tableView.reloadData()
      if random == 0 {
        self.addRandomBoastRoast()
      }
    }
    
  }
  
  func addRandomBoastRoast() {
    DispatchQueue.main.async {
      if let item = self.allSampleBoastRoastItems.randomElement() {
        let newItem = item.copy()
        newItem.timestamp = Date()
        self.tableView.beginUpdates()
        self.currentBoastRoastItems.insert(newItem, at: 0)
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
        self.tableView.endUpdates()
      }
    }
  }
  
  func loadSampleBoastRoasts() {
    Firestore.firestore().collection("latestRoastBoasts").order(by: "timestamp", descending: false).getDocuments { (snapshot, error) in
      if let error = error {
        print("Error getting message query documents: \(error)")
        return
      }
      if let snapshot = snapshot {
        for document in snapshot.documents {
          do {
            let boastRoastItem = try FirestoreDecoder().decode(LatestRoastBoastItem.self, from: document.data())
            if !self.allSampleBoastRoastItems.contains(where: { $0 == boastRoastItem }) {
              self.allSampleBoastRoastItems.append(boastRoastItem)              
            }
            
          } catch {
            print("Failed deserialization of sample boast roast: \(error)")
          }
          
        }
        for _ in 0..<5 {
          self.addRandomBoastRoast()
        }
        
      }
      
    }
  }
  
}

// MARK: - UITableVieDelegate/DataSource
extension UserContactPermissionsViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.currentBoastRoastItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.latestRoastBoastTVC.identifier,
                                                   for: indexPath) as? LatestRoastBoastTableViewCell else {
      print("Failed to dequeue reusable cell")
      return UITableViewCell()
    }
    cell.selectionStyle = .none
    let item = self.currentBoastRoastItems[indexPath.row]
    cell.configure(item: item)
    return cell
  }
  
}
