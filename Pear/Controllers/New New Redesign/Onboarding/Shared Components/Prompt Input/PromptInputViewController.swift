//
//  PromptInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class PromptInputViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var titleLabel: UILabel!
  var questionItems: [QuestionItem]!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(prompts: [QuestionItem]) -> PromptInputViewController? {
    guard let promptInputVC = R.storyboard.promptInputViewController()
      .instantiateInitialViewController() as? PromptInputViewController else { return nil }
    promptInputVC.questionItems = prompts
    return promptInputVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.dismiss(animated: true, completion: nil)
  }
  
}

// MARK: - Life Cycle
extension PromptInputViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  func setup() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
  }
  
  func stylize() {
    
  }
  
}

// MARK: - TableViewDelegate/DataSource
extension PromptInputViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.questionItems.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.promptInputTVC.identifier,
                                                   for: indexPath) as? PromptInputTableViewCell else {
                                                    print("Failed to instantiate TVC")
                                                    return UITableViewCell()
    }
    let promptItem = self.questionItems[indexPath.row]
    cell.promptLabel.text = promptItem.questionText
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let questionItem = self.questionItems[indexPath.row]
    guard let promptResponseVC = PromptInputResponseViewController.instantiate(question: questionItem) else {
      print("Question Item Response VC unable to create")
      return
    }
    self.navigationController?.pushViewController(promptResponseVC, animated: true)
  }
  
}
