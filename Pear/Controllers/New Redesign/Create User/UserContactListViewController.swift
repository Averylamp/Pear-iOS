//
//  UserContactListViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Contacts

struct ContactListItem {
  let contact: CNContact
  let phoneNumber: String
  let name: String
  var enabled: Bool = true
}

class UserContactListViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchContainerView: UIView!
  @IBOutlet weak var searchInputTextField: UITextField!
  
  var allContacts: [ContactListItem] = []
  var filteredContacts: [ContactListItem] = []
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(contacts: [CNContact]) -> UserContactListViewController? {
    guard let contactListVC = R.storyboard.userContactListViewController()
      .instantiateInitialViewController() as? UserContactListViewController else { return nil }
    contacts.forEach({
      guard let phone = $0.phoneNumbers.first?.value.stringValue.filter("0123456789".contains) else {
        return
      }
      var fullName = ""
      fullName += $0.givenName
      if $0.familyName.count > 0, let initial = $0.familyName.firstUppercased.first {
        fullName += " " + String(initial)  + "."
      }
      if fullName.count > 3 && phone.count == 10 {
        let item = ContactListItem(contact: $0, phoneNumber: phone, name: fullName, enabled: true)
        contactListVC.allContacts.append(item)
      }
    })
    contactListVC.allContacts.sort { (cl1, cl2) -> Bool in
      return cl1.name < cl2.name
    }
    contactListVC.filteredContacts.append(contentsOf: contactListVC.allContacts)
    return contactListVC
  }
  
}

// MARK: - Life Cycle
extension UserContactListViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.fetchExistingUsers()
  }

  func stylize() {
    self.view.backgroundColor = R.color.backgroundColorYellow()
    self.tableView.backgroundColor = nil
    self.tableView.separatorStyle = .none
    self.searchContainerView.layer.cornerRadius = 8
    if let font = R.font.openSansExtraBold(size: 24) {
      self.searchInputTextField.font = font
    }
  }
  
  func setup() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.searchInputTextField.delegate = self
  }
  
  func fetchExistingUsers() {
    
  }
  
}

// MARK: - UITableViewDelegate/DataSource
extension UserContactListViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.filteredContacts.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.contactLIstItemTVC.identifier, for: indexPath) as? ContactListItemTableViewCell else {
      print("Failed to create contact List item")
      return UITableViewCell()
    }
    let contactItem = self.filteredContacts[indexPath.row]
    cell.configure(contactItem: contactItem)
    
    return cell
  }
  
}

// MARK: - UITextFieldDelegate
extension UserContactListViewController: UITextFieldDelegate {
  
  func updateSearch() {
    guard let text = self.searchInputTextField.text else {
      self.filteredContacts = self.allContacts
      return
    }
    
    if text.count > 0 {
      
    } else {
      self.filteredContacts = self.allContacts
    }
    
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
    return true
  }
  
}
