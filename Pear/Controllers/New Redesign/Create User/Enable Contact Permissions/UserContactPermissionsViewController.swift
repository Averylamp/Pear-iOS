//
//  UserContactPermissionsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAnalytics
import CodableFirebase
import ContactsUI

class UserContactPermissionsViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var numberProfilesLabel: UILabel!
  @IBOutlet weak var pickContactButton: UIButton!
  @IBOutlet weak var tableViewContainerView: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var skipButtonHeight: NSLayoutConstraint!
  
  var allSampleBoastRoastItems: [LatestRoastBoastItem] = []
  var currentBoastRoastItems: [LatestRoastBoastItem] = []
  var lastBoastRoastAddTime: Date = Date(timeIntervalSinceNow: -60)
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> UserContactPermissionsViewController? {
    guard let contactPermissionsVC = R.storyboard.userContactPermissionsViewController
      .instantiateInitialViewController()  else { return nil }
    return contactPermissionsVC
  }
  
  @IBAction func pickContactButtonClicked(_ sender: Any) {
    self.promptContactsPicker()
  }
  
  @IBAction func skipButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    let controller = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
    let goBackAction = UIAlertAction(title: "Go Back", style: .default, handler: nil)
    let continueAction = UIAlertAction(title: "Continue", style: .destructive) { (_) in
      DispatchQueue.main.async {
        guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
          print("Failed to create main VC")
          return
        }
        self.navigationController?.setViewControllers([mainVC], animated: true)
      }
    }
    controller.addAction(goBackAction)
    controller.addAction(continueAction)
    self.present(controller, animated: true, completion: nil)
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
    if let font = R.font.openSansSemiBold(size: 20) {
      self.numberProfilesLabel.font = font
    }
    self.numberProfilesLabel.textColor = UIColor.white
    self.numberProfilesLabel.text = ""
    
    DataStore.shared.checkForDetachedProfiles(detachedProfilesFound: { (detachedProfiles) in
      DispatchQueue.main.async {
      print("\(detachedProfiles.count) Detached Profiles Found")
        if let writerFirstName = detachedProfiles.first?.creatorFirstName {
          
          if detachedProfiles.count > 1 {
            self.stylizeSubtitleLabel(firstLine: "\(writerFirstName) & \(detachedProfiles.count) others are pearing you.", secondLine: "Pick a fresh pear to see what they said!")
          } else {
            self.stylizeSubtitleLabel(firstLine: "\(writerFirstName) peared you.", secondLine: "Pick a fresh pear to see what they said!")
          }
        } else {
          DataStore.shared.getWaitlistNumber(completion: { (number) in
            DispatchQueue.main.async {
              self.stylizeSubtitleLabel(firstLine: "\(number + Int.random(in: 0..<2)) people in Boston", secondLine: "are using Pear with their friends.")
            }
          })
        }
      }
    })
    
    if let font = R.font.openSansBold(size: 18) {
      self.pickContactButton.titleLabel?.font = font
    }
    self.pickContactButton.setTitleColor(UIColor.black, for: .normal)
    self.pickContactButton.backgroundColor = R.color.backgroundColorYellow()
    self.pickContactButton.layer.cornerRadius = self.pickContactButton.frame.height / 2.0
    
    self.tableViewContainerView.layer.cornerRadius = 12
    self.tableViewContainerView.clipsToBounds = true
    self.tableViewContainerView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
    self.tableView.backgroundColor = nil
    self.tableView.separatorStyle = .none
    self.skipButtonHeight.constant = 30
    self.skipButton.isEnabled = true
    self.skipButton.isHidden = false
  }
  
  func stylizeSubtitleLabel(firstLine: String, secondLine: String) {
    guard let boldFont = R.font.openSansExtraBold(size: 20),
      let regularFont = R.font.openSansSemiBold(size: 20) else {
        print("Unable to get fonts")
        return
    }
    let attributedText = NSMutableAttributedString(string: firstLine + "\n",
                                                  attributes: [NSAttributedString.Key.font: boldFont])
    attributedText.append(NSAttributedString(string: secondLine,
                                             attributes: [NSAttributedString.Key.font: regularFont]))
    self.numberProfilesLabel.attributedText = attributedText
  }
  
  func setup() {
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.startRunLoop()
  }
  
  func startRunLoop() {
    _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
      let random = Int.random(in: 0..<2)
      self.tableView.reloadData()
      if random == 0 {
        self.addRandomBoastRoast()
      }
    }
    
  }
  
  func addRandomBoastRoast(date: Date = Date()) {
    if date.timeIntervalSince(self.lastBoastRoastAddTime) <= 3 {
      return
    }
    self.lastBoastRoastAddTime = date
    DispatchQueue.main.async {
      
      if let item = self.allSampleBoastRoastItems.first(where: {!self.currentBoastRoastItems.contains($0) }) {
        
        let newItem = item.copy()
        newItem.timestamp = date
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
        self.allSampleBoastRoastItems = self.allSampleBoastRoastItems.shuffled()
        self.addRandomBoastRoast(date: Date(timeIntervalSinceNow: -23))
        self.addRandomBoastRoast(date: Date(timeIntervalSinceNow: -18))
        self.addRandomBoastRoast(date: Date(timeIntervalSinceNow: -15))
        self.addRandomBoastRoast(date: Date(timeIntervalSinceNow: -11))
        self.addRandomBoastRoast(date: Date(timeIntervalSinceNow: -4))
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

// MARK: ProfileCreationProtocol
extension UserContactPermissionsViewController: ProfileCreationProtocol, CNContactPickerDelegate {
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    self.didSelectContact(contact: contact)
  }
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
    self.didSelectContactProperty(contactProperty: contactProperty)
  }
  
  func receivedProfileCreationData(creationData: ProfileCreationData) {
    DispatchQueue.main.async {
      guard let vibesVC = ProfileInputVibeViewController.instantiate(profileCreationData: creationData) else {
        print("Failed to create Vibes VC")
        return
      }
      self.navigationController?.pushViewController(vibesVC, animated: true)
    }
  }
  
  func recievedProfileCreationError(title: String, message: String?) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true)
    }
  }
  
  func promptContactsPicker() {
    let cnPicker = self.getContactsPicker()
    cnPicker.delegate = self
    self.present(cnPicker, animated: true, completion: nil)
  }
  
}
