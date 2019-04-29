//
//  FullChatViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class FullChatViewController: UIViewController {
  
  var match: Match!
  var chat: Chat!
  
  @IBOutlet weak var firstNameButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var inputContainerView: UIView!
  @IBOutlet weak var inputContainerViewHeightConstraint: NSLayoutConstraint?
  @IBOutlet weak var inputContainerViewBottomConstraint: NSLayoutConstraint!
  
  var textViewHeigtConstraint: NSLayoutConstraint?
  var inputTextView: UITextView?
  var minTextViewSize: CGFloat = 32
  var animationDuration: Double = 0.3
  var maxHeight: CGFloat = 100
  let placeholderText: String = "Say something..."
  var sendingMessage = false
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
    Analytics.logEvent("CHAT_thread_TAP_firstNameToProfile", parameters: nil)
    self.goToFullProfile()
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func moreOptionsButtonClicked(_ sender: Any) {
    Analytics.logEvent("CHAT_thread_TAP_moreOptions", parameters: nil)

    let alertController = UIAlertController()
    let unmatch = UIAlertAction(title: "Unmatch", style: .destructive) { (_) in
      guard let userID = DataStore.shared.currentPearUser?.documentID else {
        print("Failed to get pear user")
        return
      }
      PearMatchesAPI.shared.unmatchRequest(uid: userID, matchID: self.match.documentID, reason: nil, completion: { (result) in
        switch result {
        case .success(let successful):
          DispatchQueue.main.async {
            if successful {
              print("Successfully unmatches")
              HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
              Analytics.logEvent("CHAT_thread_EV_unmatched", parameters: nil)
            } else {
              print("Failed to Unmatch")
              HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
            }
          }
        case .failure(let error):
          print("Error unmatching: \(error)")
        }
        DataStore.shared.refreshMatchRequests(matchRequestsFound: nil)
        DataStore.shared.refreshCurrentMatches(matchRequestsFound: nil)
      
        DispatchQueue.main.async {
          self.navigationController?.popViewController(animated: true)
        }

      })
    }
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(unmatch)
    alertController.addAction(cancel)
    self.present(alertController, animated: true, completion: nil)
  }
  
}

// MARK: - Life Cycle
extension FullChatViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
    self.stylizeInputView()
    self.addKeyboardSizeNotifications()
    self.addDismissKeyboardOnViewClick()

  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    self.recalculateTextViewHeight(animated: false)
    self.tableView.reloadData()
    self.tableView.scrollToRow(at: IndexPath(row: self.chat.messages.count - 1, section: 0), at: .bottom, animated: false)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    NotificationCenter.default.post(name: .refreshChatsTab, object: nil)
    self.tableView.scrollToRow(at: IndexPath(row: self.chat.messages.count - 1, section: 0), at: .bottom, animated: true)
  }
  
  func stylize() {
    self.firstNameButton.titleLabel?.stylizeFullChatNameHeader()
    self.firstNameButton.setTitleColor(R.color.primaryTextColor(), for: .normal)
    self.firstNameButton.setTitle(match.otherUser.firstName, for: .normal)
    
    self.tableView.backgroundColor = nil
    self.tableView.separatorStyle = .none
  }
  
  func setup() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.chat.delegate = self
    self.chat.subscribeToMessages()
    self.chat.updateLastSeenTime(completion: nil)
  }
  
  func goToFullProfile() {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    let fullProfile = FullProfileDisplayData(user: match.otherUser)
    guard let fullProfileScrollVC = FullProfileScrollViewController.instantiate(fullProfileData: fullProfile) else {
      print("failed to instantiate full profile scroll VC")
      return
    }
    self.navigationController?.pushViewController(fullProfileScrollVC, animated: true)
  }
  
  @objc func acceptRequestButtonClicked() {
    Analytics.logEvent("CHAT_request_TAP_acceptButton", parameters: nil)
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.respondToRequest(accepted: true)
  }
  
  @objc func declineRequestButtonClicked() {
    Analytics.logEvent("CHAT_request_TAP_declineButton", parameters: nil)
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.respondToRequest(accepted: false)
  }
  
  func respondToRequest(accepted: Bool) {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Failed to get current User")
      return
    }
    PearMatchesAPI.shared.decideOnMatchRequest(uid: userID,
                                               matchID: match.documentID, accepted: accepted) { (result) in
                                                NotificationCenter.default.post(name: .refreshChatsTab, object: nil)
                                                DataStore.shared.refreshMatchRequests(matchRequestsFound: nil)
                                                DataStore.shared.refreshCurrentMatches(matchRequestsFound: nil)
                                                switch result {
                                                case .success(let match):
                                                  self.match = match
                                                  match.fetchFirebaseChatObject(completion: { (match) in
                                                    if let match = match {
                                                      self.match = match
                                                      self.chat = match.chat!
                                                      if match.otherUserStatus == .accepted && match.currentUserStatus == .accepted {
                                                        DispatchQueue.main.async {
                                                          HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
                                                          self.chat.delegate = self
                                                          self.chat.subscribeToMessages()
                                                          self.tableView.reloadData()
                                                          self.stylizeInputView()
                                                        }
                                                      } else {
                                                        DispatchQueue.main.async {
                                                          HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
                                                          self.navigationController?.popViewController(animated: true)
                                                        }
                                                      }
                                                    }
                                                  })
                                                case .failure(let error):
                                                  DispatchQueue.main.async {
                                                    HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)                                                    
                                                  }
                                                  print("Failed to respond to request: \(error)")
                                                }
    } 
  }
  
  @objc func sendMessageButtonClicked() {
    Analytics.logEvent("CHAT_thread_TAP_sendMessage", parameters: nil)
    self.sendMessage()
  }
  
  func sendMessage() {
    if let inputTextView = self.inputTextView {
      
      if let messageText = inputTextView.text,
        messageText != "",
        messageText != self.placeholderText,
        !self.sendingMessage {
        self.sendingMessage = true
        inputTextView.text = ""
        self.recalculateTextViewHeight(animated: true)
        self.chat.sendMessage(text: messageText) { (error) in
          self.sendingMessage = false
          if let error = error {
            print("Error sending message: \(error)")
          }
        }
      }
    }
  }
  
  func stylizeInputView() {
    self.inputContainerView.subviews.forEach({ $0.removeFromSuperview() })
    if match.currentUserStatus == .undecided {
      if let inputContainerHeightConstraint = self.inputContainerViewHeightConstraint, inputContainerHeightConstraint.isActive {
        inputContainerHeightConstraint.isActive = false
      }
      let acceptButton = UIButton()
      acceptButton.addTarget(self, action: #selector(FullChatViewController.acceptRequestButtonClicked), for: .touchUpInside)
      acceptButton.setTitle("Accept", for: .normal)
      acceptButton.translatesAutoresizingMaskIntoConstraints = false
      acceptButton.addConstraint(NSLayoutConstraint(item: acceptButton, attribute: .height, relatedBy: .equal,
                                                    toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0))
      self.inputContainerView.addSubview(acceptButton)
      self.inputContainerView.addConstraints([
        NSLayoutConstraint(item: acceptButton, attribute: .left, relatedBy: .equal, toItem: self.inputContainerView, attribute: .left, multiplier: 1.0, constant: 20.0),
        NSLayoutConstraint(item: acceptButton, attribute: .right, relatedBy: .equal, toItem: self.inputContainerView, attribute: .right, multiplier: 1.0, constant: -20.0),
        NSLayoutConstraint(item: acceptButton, attribute: .top, relatedBy: .equal, toItem: self.inputContainerView, attribute: .top, multiplier: 1.0, constant: 8.0)
        ])
      
      let declineButton = UIButton()
      declineButton.addTarget(self, action: #selector(FullChatViewController.declineRequestButtonClicked), for: .touchUpInside)
      declineButton.setTitle("Decline", for: .normal)
      declineButton.translatesAutoresizingMaskIntoConstraints = false
      declineButton.addConstraint(NSLayoutConstraint(item: declineButton, attribute: .height, relatedBy: .equal,
                                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0))
      self.inputContainerView.addSubview(declineButton)
      self.inputContainerView.addConstraints([
        NSLayoutConstraint(item: declineButton, attribute: .left, relatedBy: .equal, toItem: self.inputContainerView, attribute: .left, multiplier: 1.0, constant: 20.0),
        NSLayoutConstraint(item: declineButton, attribute: .right, relatedBy: .equal, toItem: self.inputContainerView, attribute: .right, multiplier: 1.0, constant: -20.0),
        NSLayoutConstraint(item: declineButton, attribute: .top, relatedBy: .equal, toItem: acceptButton, attribute: .bottom, multiplier: 1.0, constant: 8.0)
        ])
      
      let infoLabel = UILabel()
      infoLabel.textAlignment = .center
      infoLabel.translatesAutoresizingMaskIntoConstraints = false
      infoLabel.stylizeChatRequestPreviewTextLabel(unread: false)
      infoLabel.numberOfLines = 0
      infoLabel.text = "If \(match.otherUser.firstName ?? "they") also accepts, they'll see your message and you'll be able to chat with each other."
      self.inputContainerView.addSubview(infoLabel)
      self.inputContainerView.addConstraints([
        NSLayoutConstraint(item: infoLabel, attribute: .left, relatedBy: .equal, toItem: self.inputContainerView, attribute: .left, multiplier: 1.0, constant: 20.0),
        NSLayoutConstraint(item: infoLabel, attribute: .right, relatedBy: .equal, toItem: self.inputContainerView, attribute: .right, multiplier: 1.0, constant: -20.0),
        NSLayoutConstraint(item: infoLabel, attribute: .top, relatedBy: .equal,
                           toItem: declineButton, attribute: .bottom, multiplier: 1.0, constant: 8.0),
        NSLayoutConstraint(item: infoLabel, attribute: .bottom, relatedBy: .equal,
                           toItem: self.inputContainerView, attribute: .bottom, multiplier: 1.0, constant: -8.0)
        ])
      
      self.view.layoutIfNeeded()
      
      acceptButton.stylizeChatAccept()
      declineButton.stylizeLight()

    } else {
      if let inputContainerHeightConstraint = self.inputContainerViewHeightConstraint, inputContainerHeightConstraint.isActive {
        inputContainerHeightConstraint.isActive = false
      }
      let inputContainer = UIView()
      
      inputContainer.layer.cornerRadius = 8
      inputContainer.layer.borderWidth = 1.0
      inputContainer.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
      inputContainer.translatesAutoresizingMaskIntoConstraints = false
      
      let inputTextView = UITextView()
      inputTextView.stylizeChatInputPlaceholder()
      self.inputTextView = inputTextView
      inputTextView.text = self.placeholderText
      inputTextView.delegate = self
      inputTextView.translatesAutoresizingMaskIntoConstraints = false
      self.textViewHeigtConstraint = NSLayoutConstraint(item: inputTextView, attribute: .height, relatedBy: .equal,
                                                        toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0)
      inputTextView.addConstraint(self.textViewHeigtConstraint!)
      inputContainer.addSubview(inputTextView)
      inputContainer.addConstraints([
        NSLayoutConstraint(item: inputTextView, attribute: .top, relatedBy: .equal,
                           toItem: inputContainer, attribute: .top, multiplier: 1.0, constant: 2.0),
        NSLayoutConstraint(item: inputTextView, attribute: .left, relatedBy: .equal,
                           toItem: inputContainer, attribute: .left, multiplier: 1.0, constant: 8.0),
        NSLayoutConstraint(item: inputTextView, attribute: .right, relatedBy: .equal,
                           toItem: inputContainer, attribute: .right, multiplier: 1.0, constant: -8.0),
        NSLayoutConstraint(item: inputTextView, attribute: .bottom, relatedBy: .equal,
                           toItem: inputContainer, attribute: .bottom, multiplier: 1.0, constant: -2.0)
        ])
      
      let sendButton = UIButton()
      sendButton.addTarget(self, action: #selector(FullChatViewController.sendMessageButtonClicked), for: .touchUpInside)
      sendButton.translatesAutoresizingMaskIntoConstraints = false
      sendButton.setImage(R.image.chatIconSend(), for: .normal)
      sendButton.addConstraints([
        NSLayoutConstraint(item: sendButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 32),
        NSLayoutConstraint(item: sendButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 32)
        ])
      self.inputContainerView.addSubview(sendButton)
      self.inputContainerView.addSubview(inputContainer)
      
      self.inputContainerView.addConstraints([
          NSLayoutConstraint(item: sendButton, attribute: .centerY, relatedBy: .equal,
                             toItem: self.inputContainerView as Any, attribute: .centerY, multiplier: 1.0, constant: 0.0),
          NSLayoutConstraint(item: sendButton, attribute: .right, relatedBy: .equal,
                             toItem: self.inputContainerView as Any, attribute: .right, multiplier: 1.0, constant: -8.0),
          NSLayoutConstraint(item: sendButton, attribute: .left, relatedBy: .equal,
                             toItem: inputContainer, attribute: .right, multiplier: 1.0, constant: 8.0),
          NSLayoutConstraint(item: inputContainer, attribute: .left, relatedBy: .equal,
                             toItem: self.inputContainerView as Any, attribute: .left, multiplier: 1.0, constant: 8.0),
          NSLayoutConstraint(item: inputContainer, attribute: .top, relatedBy: .equal,
                             toItem: self.inputContainerView as Any, attribute: .top, multiplier: 1.0, constant: 8.0),
          NSLayoutConstraint(item: inputContainer, attribute: .bottom, relatedBy: .equal,
                             toItem: self.inputContainerView, attribute: .bottom, multiplier: 1.0, constant: -8.0),
          NSLayoutConstraint(item: self.inputContainerView as Any, attribute: .height, relatedBy: .greaterThanOrEqual,
                             toItem: sendButton, attribute: .height, multiplier: 1.0, constant: 8.0)
        ])
      self.recalculateTextViewHeight(animated: false)

    }
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
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
    
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = self.chat.messages[indexPath.row]
    switch message.type {
    case .matchmakerRequest, .personalRequest:
      var matchmakerMessage = ""
      if message.type == .matchmakerRequest {
        matchmakerMessage = "\(match.sentByUser.firstName ?? "Someone") peared you and \(match.otherUser.firstName ?? "their friend")"
      } else {
        matchmakerMessage = "\(match.sentByUser.firstName ?? "Someone") requested to match with you"
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
      var initialChatCell: ChatMessageTableViewCell?
      guard let messageSender = message.senderType else {
        print("No sender found")
        return UITableViewCell()
      }
      if messageSender == .receiver {
        initialChatCell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageTVCReceiver", for: indexPath) as? ChatMessageTableViewCell
        if let thumbnailURLString = match.otherUser.displayedImages.first?.thumbnail.imageURL,
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
      chatCell.delegate = self
      chatCell.selectionStyle = .default
      chatCell.selectionStyle = .none
      chatCell.backgroundColor = nil
      chatCell.configure(message: message)
      chatCell.layoutIfNeeded()
      chatCell.chatBubbleButton.tag = indexPath.row
      chatCell.chatBubbleButton.addTarget(self, action: #selector(FullChatViewController.chatBubbleClicked(sender:)), for: .touchUpInside)
      return chatCell
    case .serverMessage:
      guard let serverMessageCell = tableView.dequeueReusableCell(withIdentifier: "ChatServerMessageTVC", for: indexPath) as? ServerMessageTableViewCell else {
        print("Failed to instantiate server messaage")
        return UITableViewCell()
      }
      serverMessageCell.configure(message: message)
      return serverMessageCell
    }
  }
  
  @objc func chatBubbleClicked(sender: UIButton) {
    Analytics.logEvent("CHAT_thread_TAP_chatBubble", parameters: nil)
    if sender.tag < self.chat.messages.count {
      CATransaction.begin()
      CATransaction.setAnimationDuration(0.4)
      self.tableView.beginUpdates()
      if self.tableView.indexPathForSelectedRow == IndexPath(row: sender.tag, section: 0) {
        self.tableView.deselectRow(at: IndexPath(row: sender.tag, section: 0), animated: true)
      } else {
        self.tableView.selectRow(at: IndexPath(row: sender.tag, section: 0), animated: true, scrollPosition: .none)
      }
      self.tableView.endUpdates()
      CATransaction.commit()
    }
  
  }
  
}

// MARK: - Keybaord Size Notifications
extension FullChatViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(FullChatViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(FullChatViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetFrame = targetFrameNSValue.cgRectValue
      self.inputContainerViewBottomConstraint.constant = targetFrame.height - self.view.safeAreaInsets.bottom
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  @objc func keyboardWillHide(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      self.inputContainerViewBottomConstraint.constant = 0
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
}

// MARK: - UITextViewDelegate
extension FullChatViewController: UITextViewDelegate {
  
  func recalculateTextViewHeight(animated: Bool = true) {
    if let viewHeightConstraint = self.textViewHeigtConstraint, let inputTextView = self.inputTextView {
      self.view.layoutIfNeeded()
      let textHeight = inputTextView.sizeThatFits(CGSize(width: inputTextView.frame.width,
                                                                  height: CGFloat.greatestFiniteMagnitude)).height
      viewHeightConstraint.constant = max(minTextViewSize, textHeight)
      if maxHeight < viewHeightConstraint.constant {
        inputTextView.isScrollEnabled = true
        viewHeightConstraint.constant = maxHeight
      } else {
        inputTextView.isScrollEnabled = false
      }
      if animated {
        UIView.animate(withDuration: self.animationDuration) {
          self.view.layoutIfNeeded()
        }
      } else {
        self.view.layoutIfNeeded()
      }
    }
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == self.placeholderText {
      textView.text = ""
      textView.stylizeChatInputText()
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text == "" {
      textView.text = self.placeholderText
      textView.stylizeChatInputPlaceholder()
    }
  }
  
  func textViewDidChange(_ textView: UITextView) {
    self.recalculateTextViewHeight()
  }
  
}

// MARK: - Dismiss First Responder on Click
extension FullChatViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FullChatViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    Analytics.logEvent("CHAT_thread_EV_dismissKeyboard", parameters: nil)
    self.view.endEditing(true)
  }
}

// MARK: - ChatDelegate
extension FullChatViewController: ChatDelegate {
  func receivedNewMessages() {
    DispatchQueue.main.async {
      HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
      self.tableView.reloadData()
      self.tableView.scrollToRow(at: IndexPath(row: self.chat.messages.count - 1, section: 0), at: .bottom, animated: true)
      NotificationCenter.default.post(name: .refreshChatsTab, object: nil)
      self.chat.updateLastSeenTime(completion: nil)
    }
  }
}

// MARK: - MesageTableCellDelegate
extension FullChatViewController: ChatMessageCellDelegate {
  func clickedOnIcon() {
    DispatchQueue.main.async {
      self.goToFullProfile()
    }
  }
}
