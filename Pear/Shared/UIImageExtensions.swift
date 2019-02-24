//
//  UIImageExtensions.swift
//  Pear
//
//  Created by Avery Lamp on 2/11/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

extension UIImage {
    func imageWith(newSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let image = renderer.image { _ in
            self.draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
        }
        return image
    }
    
    func gettingStartedImage() -> GettingStartedUIImage{
        return GettingStartedUIImage(data: self.pngData()!)!
    }
}

class GettingStartedUIImage: UIImage{
    var imageSizesRepresentation: ImageAllSizesRepresentation?
    
}
