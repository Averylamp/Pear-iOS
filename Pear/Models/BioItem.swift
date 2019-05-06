//
//  BioItem.swift
//  Pear
//
//  Created by Avery Lamp on 4/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

class BioItem: TextContentItem {
  override func copy(with zone: NSZone? = nil) -> Any {
    let item = BioItem(content: self.content, hidden: self.hidden)
    item.documentID = self.documentID
    item.authorID = self.authorID
    item.authorFirstName = self.authorFirstName
    return item
  }
}
