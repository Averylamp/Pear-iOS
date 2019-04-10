//
//  ChatRequestsTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 4/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

protocol ChatRequestsTableViewCellDelegate: class {
  func didSelectThumbnailAtIndex(index: Int)
}

class ChatRequestsTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var previewTextLabel: UILabel!
  @IBOutlet weak var timestampLabel: UILabel!
  @IBOutlet weak var thumbnailImage: UIImageView!
  weak var delegate: ChatRequestsTableViewCellDelegate?
  var index: Int?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.nameLabel.stylizeChatRequestNameLabel(unread: false)
    self.previewTextLabel.stylizeChatRequestNameLabel(unread: false)
    self.timestampLabel.stylizeChatRequestDateLabel(unread: false)
    self.thumbnailImage.contentMode = .scaleAspectFill
    self.thumbnailImage.clipsToBounds = true
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  @IBAction func thumbnailImageClicked(_ sender: Any) {
    if let index = index, let delegate = delegate {
      delegate.didSelectThumbnailAtIndex(index: index)
    }
  }
  
}

extension ChatRequestsTableViewCell {
  
  func configure(match: Match, index: Int) {
    self.index = index
    self.nameLabel.stylizeChatRequestNameLabel(unread: false)
    self.previewTextLabel.stylizeChatRequestNameLabel(unread: false)
    self.timestampLabel.stylizeChatRequestDateLabel(unread: false)
    
    self.nameLabel.text = match.otherUser.firstName
    self.thumbnailImage.layer.cornerRadius = self.thumbnailImage.frame.width / 2.0
    self.thumbnailImage.image = nil
    if let thumbnailURLString = match.otherUser.images.first?.thumbnail.imageURL,
      let thumbnailURL = URL(string: thumbnailURLString) {
      self.thumbnailImage.sd_setImage(with: thumbnailURL, completed: nil)
    }
    
    if let mostRecentMessage = match.chat?.messages.last {
      self.previewTextLabel.text = mostRecentMessage.content
      self.timestampLabel.text = mostRecentMessage.timestamp.timeAgoSinceDate()
    } else {
      self.previewTextLabel.text = "..."
      self.timestampLabel.text = ""
    }
    
  }
  
}
