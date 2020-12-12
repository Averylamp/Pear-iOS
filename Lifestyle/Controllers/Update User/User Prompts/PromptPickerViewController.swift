//
//  PromptPickerViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

protocol PromptPickerDelegate: class {
  
  func didReplacePrompt(prompt: QuestionResponseItem, atIndex: Int?)
  
}

class PromptPickerViewController: UIViewController {
  
  weak var promptPickerDelegate: PromptPickerDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var titleLabel: UILabel!
  
  var allPrompts: [QuestionResponseItem] = []
  
  var replaceIndex: Int?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(replaceIndex: Int?) -> PromptPickerViewController? {
    guard let promptPickerVC = R.storyboard.promptPickerViewController
      .instantiateInitialViewController() else { return nil }
    promptPickerVC.replaceIndex = replaceIndex
    return promptPickerVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - Life Cycle
extension PromptPickerViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  func setup() {
    guard let prompts = DataStore.shared.currentPearUser?.questionResponses else {
      print("Unable to get user prompts")
      return
    }
    self.allPrompts = prompts.sorted(by: { (qr1, qr2) -> Bool in
      if qr1.hidden == false && qr2.hidden == true {
        return true
      }
      if qr2.hidden == false && qr1.hidden == true {
        return false
      }
      return qr1.authorID.compare(qr2.authorID) == .orderedAscending
    })
    self.tableView.dataSource = self
    self.tableView.delegate = self
  }
  
  func stylize() {
    self.titleLabel.stylizeGeneralHeaderTitleLabel()
    self.tableView.separatorStyle = .none
  }
  
}

// MARK: - UITableViewDataSource/Delegate
extension PromptPickerViewController: UITableViewDataSource, UITableViewDelegate {
 
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allPrompts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.promptTVC.identifier, for: indexPath) as? PromptTableViewCell else {
      print("Unable to dequeue Cell")
      return UITableViewCell()
    }
    let prompt = self.allPrompts[indexPath.row]
    cell.stylize(prompt: prompt)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let prompt = self.allPrompts[indexPath.row]
    if prompt.hidden == true {
      HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
      if let delegate = self.promptPickerDelegate {
        delegate.didReplacePrompt(prompt: prompt, atIndex: self.replaceIndex)
      }
      self.navigationController?.popViewController(animated: true)
    }
  }
  
}
