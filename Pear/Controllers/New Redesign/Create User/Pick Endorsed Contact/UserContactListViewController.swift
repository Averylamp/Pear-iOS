//
//  UserContactListViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Contacts

struct ContactListItem: Comparable {
  static func < (lhs: ContactListItem, rhs: ContactListItem) -> Bool {
    if lhs.score < rhs.score {
      return true
    } else if lhs.score > rhs.score {
      return false
    }
    return lhs.name < rhs.name
  }
  
  let contact: CNContact
  let phoneNumber: String
  let name: String
  let firstName: String
  let lastName: String
  var score: Double = 0
  var enabled: Bool = true
  
}

class UserContactListViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchContainerView: UIView!
  @IBOutlet weak var searchInputTextField: UITextField!
  @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
  
  var allContacts: [ContactListItem] = []
  var filteredContacts: [ContactListItem] = []
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(contacts: [CNContact]) -> UserContactListViewController? {
    guard let contactListVC = R.storyboard.userContactListViewController()
      .instantiateInitialViewController() as? UserContactListViewController else { return nil }
    contacts.forEach({
      guard var phone = $0.phoneNumbers.first?.value.stringValue.filter("0123456789".contains) else {
        return
      }
      if phone.count == 11 && phone.first == "1" {
        phone = phone.substring(fromIndex: 1)
      }
      var fullName = ""
      let firstName = $0.givenName
      let lastName = $0.familyName
      fullName += $0.givenName
      if $0.familyName.count > 0, let initial = $0.familyName.firstUppercased.first {
        fullName += " " + String(initial)  + "."
      }
      if fullName.count > 3 && (phone.count == 10 ) {
        let item = ContactListItem(contact: $0,
                                   phoneNumber: phone,
                                   name: fullName,
                                   firstName: firstName,
                                   lastName: lastName,
                                   score: 0,
                                   enabled: true)
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
    self.addKeyboardSizeNotifications()
  }
  
  func stylize() {
    self.view.backgroundColor = R.color.backgroundColorYellow()
    self.tableView.backgroundColor = nil
    self.tableView.separatorStyle = .none
    self.searchContainerView.layer.cornerRadius = 8
    if let font = R.font.openSansExtraBold(size: 24) {
      self.searchInputTextField.font = font
    }
    
    if let font = R.font.openSansExtraBold(size: 16) {
      self.titleLabel.font = font
    }
    self.titleLabel.textColor = UIColor.white
    
  }
  
  func setup() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.searchInputTextField.delegate = self
    self.searchInputTextField.addTarget(self, action: #selector(UserContactListViewController.updateSearch), for: .editingChanged)
  }
  
  func fetchExistingUsers() {
    PearUserAPI.shared.getExistingUsers(checkNumbers: allContacts.map({ $0.phoneNumber })) { (result) in
      switch result {
      case .success(let existingUsersPhoneNumbers):
        print("Found Existing Phone Numbers: \(existingUsersPhoneNumbers)")
        let phoneNumberSet = Set(existingUsersPhoneNumbers)
        
        for index in 0..<self.filteredContacts.count where phoneNumberSet.contains(self.filteredContacts[index].phoneNumber) {
          self.filteredContacts[index].enabled = false
        }
        
      case .failure(let error):
        print("Failed to find existing users: \(error)")
      }
    }
  }
  
}

// MARK: - UITableViewDelegate/DataSource
extension UserContactListViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    let selectedContactListItem = self.filteredContacts[indexPath.row]
    let profileCreationData = ProfileCreationData(contactListItem: selectedContactListItem)
    guard let vibeVC = ProfileInputVibeViewController.instantiate(profileCreationData: profileCreationData) else {
      print("Faile to created Vibe VC")
      return
    }
    self.navigationController?.pushViewController(vibeVC, animated: true)
  }
  
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
  
  @objc func updateSearch() {
    guard let text = self.searchInputTextField.text else {
      self.filteredContacts = self.allContacts
      return
    }
    
    if text.count > 0 {
      for index in 0..<filteredContacts.count {
        let item = self.filteredContacts[index]
        let itemText = item.name.lowercased() + item.phoneNumber
        let lengthDiff = abs(itemText.count - text.count)
        self.filteredContacts[index].score = 0
        for characterIndex in 0..<(itemText.count < text.count ? itemText.count : text.count) {
          if text.lowercased()[characterIndex].compare(itemText.lowercased()[characterIndex]) == .orderedSame {
            self.filteredContacts[index].score += 100
          } else {
            break
          }
        }
        self.filteredContacts[index].score -= Double(text.lowercased().levenshtein(itemText) + lengthDiff)
      }
      self.filteredContacts.sort()
      self.filteredContacts.reverse()
      self.tableView.reloadData()
      if self.filteredContacts.count > 0 {
        DispatchQueue.main.async {
          self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
      }
    } else {
      for index in 0..<filteredContacts.count {
        self.filteredContacts[index].score = 0
      }
      self.filteredContacts = self.allContacts
    }
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return true
  }
  
}

// MARK: - Keybaord Size Notifications
extension UserContactListViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(UserContactListViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(UserContactListViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetFrame = targetFrameNSValue.cgRectValue
      self.tableViewBottomConstraint.constant = targetFrame.height - self.view.safeAreaInsets.bottom
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  @objc func keyboardWillHide(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      self.tableViewBottomConstraint.constant = 0
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
}
