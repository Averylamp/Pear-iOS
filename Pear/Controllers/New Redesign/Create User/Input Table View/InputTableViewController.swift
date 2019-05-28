//
//  InputTableViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

protocol InputTableViewDelegate: class {
  func canSelect(response: SuggestedResponseTableItem, allItems: [SuggestedResponseTableItem]) -> Bool
  func suggestedResponseSelected(response: QuestionResponseItem, allItems: [SuggestedResponseTableItem])
}

struct SuggestedResponseTableItem {
  let suggestion: QuestionSuggestedResponse
  var selected = false
}

class InputTableViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  
  var question: QuestionItem!
  var responseItems: [SuggestedResponseTableItem] = []
  var multiselect: Bool = false
  var vibesInput: Bool = false
  
  weak var delegate: InputTableViewDelegate?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(question: QuestionItem, multiselect: Bool = false, vibesInput: Bool = false) -> InputTableViewController? {
    guard let inputTableVC = R.storyboard.inputTableViewController
      .instantiateInitialViewController() else { return nil }
    inputTableVC.question = question
    inputTableVC.responseItems = question.suggestedResponses.map({ SuggestedResponseTableItem(suggestion: $0, selected: false) })
    inputTableVC.multiselect = multiselect
    inputTableVC.vibesInput = vibesInput
    return inputTableVC
  }
  
  func getSelectedItems() -> [SuggestedResponseTableItem] {
    return self.responseItems.filter({ $0.selected })
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
  
  func tableViewContentHeight() -> CGFloat {
    self.tableView.layoutIfNeeded()
    return self.tableView.contentSize.height
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.responseItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.inputItemTVC.identifier, for: indexPath) as? InputItemTableViewCell else {
          return UITableViewCell()
    }
    let responseItem = self.responseItems[indexPath.row]
    cell.configure(inputItem: responseItem.suggestion, selected: responseItem.selected)
    if self.vibesInput, let font = R.font.openSansExtraBold(size: 18) {
      cell.contentLabel.font = font
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    let item = self.responseItems[indexPath.row]
    if let delegate = delegate,
      !delegate.canSelect(response: item, allItems: self.responseItems) {
      HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
      return nil
    }
    return indexPath
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    let selectedResponse = self.responseItems[indexPath.row]
    self.responseItems[indexPath.row].selected = true
    if let delegate = delegate,
      let questionResponse = try? QuestionResponseItem(documentID: nil,
                                                  question: self.question,
                                                  responseBody: selectedResponse.suggestion.responseBody,
                                                  responseTitle: selectedResponse.suggestion.responseTitle,
                                                  color: selectedResponse.suggestion.color,
                                                  icon: selectedResponse.suggestion.icon) {
      delegate.suggestedResponseSelected(response: questionResponse,
                                         allItems: self.responseItems)
    }
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.responseItems[indexPath.row].selected = false
  }
  
}
