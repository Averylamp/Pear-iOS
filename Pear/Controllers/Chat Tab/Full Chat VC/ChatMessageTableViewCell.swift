//
//  ChatMessageTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 4/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ChatMessageTableViewCell: UITableViewCell {

  @IBOutlet weak var chatContainerView: UIView!
  @IBOutlet weak var chatMessageLabel: UILabel!
  @IBOutlet weak var chatTimestampLabel: UILabel!
  @IBOutlet weak var chatThumbnailImageView: UIImageView?
  @IBOutlet weak var chatBackgroundImageView: UIImageView!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    chatContainerView.layer.cornerRadius = 8
    if let chatThumbnailImageView = self.chatThumbnailImageView {
      chatThumbnailImageView.layer.cornerRadius = 25
    }
  }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  func configure(message: Message) {
    guard message.type == .userMessage else {
      print("Not user message type")
      return
    }
    
    chatMessageLabel.text = message.content
    
    if let senderType = message.senderType, senderType == .sender {
//      chatBackgroundImageView.image = R.image.chatSenderBackground()
      if let chatThumbnailImageView = self.chatThumbnailImageView {
        chatThumbnailImageView.image = nil
      }
    } else {
//      chatBackgroundImageView.image = R.image.chatReceiverBackground()
      if let chatThumbnailImageView = self.chatThumbnailImageView {
        if let thumbnailURL = message.thumbnailImage {
          chatThumbnailImageView.sd_setImage(with: thumbnailURL, completed: nil)
        } else {
          chatThumbnailImageView.image = nil
        }
      }
    }
    
  }

}
