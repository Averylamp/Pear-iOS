//
//  InputTableViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

protocol InputTableViewDelegate: class{
  func canSelect(response: QuestionResponseItem, allItems: SuggestedResponseTableItem)-> Bool
  func suggestedResponseSelected(response: QuestionResponseItem, allItems: SuggestedResponseTableItem)
}

struct SuggestedResponseTableItem{
  let suggestion: QuestionSuggestedResponse
  let selected = false
}

class InputTableViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  
  
  var responseItems: [SuggestedResponseTableItem] = []
  var multiselect: Bool = false
  
  weak var delegate: InputTableViewDelegate?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(questionResponseItems: [QuestionSuggestedResponse], multiselect: Bool = false) -> InputTableViewController? {
    guard let inputTableVC = R.storyboard.profileInputVibeViewController()
      .instantiateInitialViewController() as? InputTableViewController else { return nil }
    inputTableVC.responseItems = questionResponseItems.map({ SuggestedResponseTableItem(suggestion: $0) })
    inputTableVC.multiselect = multiselect
    return inputTableVC
  }
  
}

// MARK: - Life Cycle
extension InputTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    self.tableView.backgroundColor = nil
    self.tableView.separatorStyle = .none
  }
  
  func setup() {
    if multiselect {
      self.tableView.allowsMultipleSelection = true
    }
    self.tableView.delegate = self
    self.tableView.dataSource = self
  }
  
}

// MARK: - UITableViewDelegate/DataSource
extension InputTableViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.responseItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.inputItemTVC.identifier, for: indexPath) as? InputItemTableViewCell else{
          return UITableViewCell()
    }
    let responseItem = self.responseItems[indexPath.row]
    cell.configure(inputItem: responseItem.suggestion, multiselect: self.multiselect, selected: responseItem.selected)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("Selected: \(indexPath.row)")
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    print("Deselected: \(indexPath.row)")
  }
  
  
  
}
