//
//  ChatMessageTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 4/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ChatMessageTableViewCell: UITableViewCell {

  @IBOutlet weak var chatBubbleButton: UIButton!
  @IBOutlet weak var chatContainerView: UIView!
  @IBOutlet weak var chatMessageLabel: UILabel!
  @IBOutlet weak var chatTimestampLabel: UILabel!
  @IBOutlet weak var chatThumbnailImageView: UIImageView?
  @IBOutlet weak var chatBackgroundImageView: UIImageView!
  var gradientLayer: CAGradientLayer?
  var timestamp: Date?

  override func awakeFromNib() {
    super.awakeFromNib()
    chatContainerView.layer.cornerRadius = 12
    chatContainerView.layer.masksToBounds = true
    if let chatThumbnailImageView = self.chatThumbnailImageView {
      chatThumbnailImageView.layer.cornerRadius = 25
    }

  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
//    if let gradientLayer = self.gradientLayer {
//      self.layoutIfNeeded()
//      CATransaction.begin()
//      CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .linear))
//      let multiplier: Double = self.chatContainerView.bounds.height < gradientLayer.frame.height ? 4.0 :1.0
//      CATransaction.setAnimationDuration(0.2 * multiplier)
//      gradientLayer.frame = self.chatContainerView.bounds
//      CATransaction.commit()
//    }
  }
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      if selected, let timestamp = timestamp {
        self.chatTimestampLabel.text = timestamp.timeAgoSinceDate()
      } else {
        self.chatTimestampLabel.text = nil
      }
    }
  
  func configure(message: Message) {
    guard message.type == .userMessage else {
      print("Not user message type")
      return
    }
    self.setNeedsLayout()
    self.layoutIfNeeded()
    if let existingGradientLayer = self.gradientLayer {
      existingGradientLayer.removeFromSuperlayer()
    }
    self.timestamp = message.timestamp
    chatMessageLabel.text = message.content

    self.chatMessageLabel.stylizeChatMessageText(sender: message.senderType == .sender)
    self.chatTimestampLabel.stylizeChatMessageTimestamp(sender: message.senderType == .sender)
    if let senderType = message.senderType, senderType == .sender {
      if let chatThumbnailImageView = self.chatThumbnailImageView {
        chatThumbnailImageView.image = nil
      }

      self.chatContainerView.backgroundColor = R.color.chatAccentColor()
//      let gradientLayer = CAGradientLayer()
//      self.gradientLayer = gradientLayer
//      gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
//      gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
//      if let startColor = R.color.chatGradientSenderStart()?.cgColor,
//        let endColor = R.color.chatGradientSenderEnd()?.cgColor {
//        gradientLayer.colors = [startColor, endColor]
//      }
//      gradientLayer.frame = self.chatContainerView.bounds
//      self.chatContainerView.layer.insertSublayer(gradientLayer, at: 0)
    } else {
      if let chatThumbnailImageView = self.chatThumbnailImageView {
        if let thumbnailURL = message.thumbnailImage {
          chatThumbnailImageView.sd_setImage(with: thumbnailURL, completed: nil)
        } else {
          chatThumbnailImageView.image = nil
        }
      }
      self.chatContainerView.backgroundColor = R.color.chatGradientReceiverEnd()
//      let gradientLayer = CAGradientLayer()
//      self.gradientLayer = gradientLayer
//      gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
//      gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
//      if let startColor = R.color.chatGradientReceiverStart()?.cgColor,
//        let endColor = R.color.chatGradientReceiverEnd()?.cgColor {
//        gradientLayer.colors = [startColor, endColor]
//      }
//      gradientLayer.frame = self.chatContainerView.bounds
//      self.chatContainerView.layer.insertSublayer(gradientLayer, at: 0)
    }
    self.setNeedsLayout()
  }

}
