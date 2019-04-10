//
//  FullChatViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FullChatViewController: UIViewController {

  var match: Match!
  var chat: Chat!
  
  @IBOutlet weak var firstNameButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(match: Match, chat: Chat) -> FullChatViewController? {
    let storyboard = UIStoryboard(name: String(describing: FullChatViewController.self), bundle: nil)
    guard let fullChatVC = storyboard.instantiateInitialViewController() as? FullChatViewController else { return nil }
    fullChatVC.match = match
    fullChatVC.chat = chat
    return fullChatVC
  }
  
  @IBAction func firstNameClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    let fullProfile = FullProfileDisplayData(matchingUser: match.otherUser)
    guard let fullProfileScrollVC = FullProfileScrollViewController.instantiate(fullProfileData: fullProfile) else {
      print("failed to instantiate full profile scroll VC")
      return
    }
    self.navigationController?.pushViewController(fullProfileScrollVC, animated: true)
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - Life Cycle
extension FullChatViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    self.stylize()
    self.setup()
  }

  func stylize() {
    self.firstNameButton.titleLabel?.stylizeSubtitleLabelSmall()
    self.firstNameButton.setTitleColor(R.color.primaryTextColor(), for: .normal)
    self.firstNameButton.setTitle(match.otherUser.firstName, for: .normal)
    
    self.tableView.backgroundColor = nil
    self.tableView.separatorStyle = .none
  }
  
  func setup() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
  }
  
}

extension FullChatViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}

extension FullChatViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.chat.messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = self.chat.messages[indexPath.row]
    switch message.type {
    case .matchmakerRequest, .personalRequest:
      print("Matchmaker Request: \(message.content)")
      var matchmakerMessage = ""
      if message.type == .matchmakerRequest {
        matchmakerMessage = "\(match.sentByUser.firstName) peared you and \(match.otherUser.firstName)"
      } else {
        matchmakerMessage = "\(match.sentByUser.firstName) requested to match with you"
      }
      message.matchmakerMessage = matchmakerMessage
      guard let matchmakerMessageCell = tableView.dequeueReusableCell(withIdentifier: "ChatRequestTVC", for: indexPath) as? ChatMatchmakerRequestTableViewCell else {
        print("Failed to create matchamaker request TVC")
        return UITableViewCell()
      }
      matchmakerMessageCell.backgroundColor = nil
      matchmakerMessageCell.selectionStyle = .none
      matchmakerMessageCell.configure(message: message)
      return matchmakerMessageCell
    case .userMessage:
      print("User Message: \(message.content)")
      var initialChatCell: ChatMessageTableViewCell?
      guard let messageSender = message.senderType else {
        print("No sender found")
        return UITableViewCell()
      }
      if messageSender == .receiver {
        initialChatCell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageTVCReceiver", for: indexPath) as? ChatMessageTableViewCell
        if let thumbnailURLString = match.otherUser.images.first?.thumbnail.imageURL,
          let thumbnailURL = URL(string: thumbnailURLString) {
          message.thumbnailImage = thumbnailURL
        }
      } else {
        initialChatCell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageTVCSender", for: indexPath) as? ChatMessageTableViewCell
      }
      guard let chatCell = initialChatCell else {
        print("No cell instantiated properly")
        return UITableViewCell()
      }
      chatCell.configure(message: message)
      chatCell.selectionStyle = .none
      chatCell.backgroundColor = nil
      return chatCell
    case .serverMessage:
      print("Server Message: \(message.content)")
      guard let serverMessageCell = tableView.dequeueReusableCell(withIdentifier: "ChatServerMessageTVC", for: indexPath) as? ServerMessageTableViewCell else {
        print("Failed to instantiate server messaage")
        return UITableViewCell()
      }
      serverMessageCell.configure(message: message)
      return serverMessageCell
    }
  }
  
}
