//
//  ImageUploadCollectionViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 2/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

protocol ImageUploadCollectionViewDelegate: class {
    func closeButtonClicked(tag: Int)
}

class ImageUploadCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!

    weak var closeButtonDelegate: ImageUploadCollectionViewDelegate?

    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        if let delegate = self.closeButtonDelegate {
            delegate.closeButtonClicked(tag: sender.tag)
        }
    }

}
