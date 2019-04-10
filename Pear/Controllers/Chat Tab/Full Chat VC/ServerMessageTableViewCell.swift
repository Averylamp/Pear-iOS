//
//  ServerMessageTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 4/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ServerMessageTableViewCell: UITableViewCell {
  
  @IBOutlet weak var serverMessageLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.serverMessageLabel.stylizeChatMessageServerRequest()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  func configure(message: Message) {
    guard message.type == .serverMessage else {
      print("Cant configure server message from not server type")
      return
    }
    self.serverMessageLabel.text = message.content
  }
  
}
