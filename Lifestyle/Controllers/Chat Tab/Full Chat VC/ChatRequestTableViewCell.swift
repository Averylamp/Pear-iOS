//
//  ChatTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 4/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ChatRequestTableViewCell: UITableViewCell {
  
  @IBOutlet weak var timestampOriginLabel: UILabel?
  @IBOutlet weak var chatRequestImageView: UIImageView?
  @IBOutlet weak var chatRequestLabel: UILabel?
  @IBOutlet weak var requestContentLabel: UILabel?
  @IBOutlet weak var chatRequestContentContainerView: UIView?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if let timestampLabel = self.timestampOriginLabel {
      timestampLabel.stylizeChatMessageServerRequest()
    }
    if let requestContentLabel = self.requestContentLabel {
      requestContentLabel.stylizeChatMessageText(sender: false)
    }
    if let chatRequestLabel = self.chatRequestLabel {
      chatRequestLabel.stylizeChatMessageText(sender: false)
    }
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func configure(message: Message) {
    guard message.type == .matchmakerRequest || message.type == .personalRequest else {
      print("Should not be configuring a non request type with a Request TV cell")
      return
    }
    
    if let timestampOriginLabel = self.timestampOriginLabel {
      timestampOriginLabel.text = message.timestamp.timeAgoSinceDate()
    }
    if let chatRequestImageView = self.chatRequestImageView {
      chatRequestImageView.image = R.image.chatIconCelebrate()
    }
    if let chatRequestLabel = self.chatRequestLabel {
      if  let chatRequestText = message.matchmakerMessage {
        chatRequestLabel.text = chatRequestText
        chatRequestLabel.isHidden = false
      } else {
        chatRequestLabel.isHidden = true
      }
    }
    if let requestContentLabel = self.requestContentLabel {
      requestContentLabel.text = message.content
      if let requestContainerView = self.chatRequestContentContainerView {
        if message.content == ""{
          requestContainerView.isHidden = true
        } else {
          requestContainerView.isHidden = false
        }
      }
    }
  }
  
}
