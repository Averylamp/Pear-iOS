//
//  ImageUploadCollectionViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 2/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ImageUploadAddCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!

  weak var imageCellDelegate: ImageUploadCollectionViewDelegate?
  
  @IBAction func cellClicked(_ sender: Any) {
    if let delegate = self.imageCellDelegate {
      delegate.imageClicked(tag: self.tag)
    }
  }

}
