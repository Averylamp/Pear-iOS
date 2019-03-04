//
//  ImageAllSizesRepresentation.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 sam. All rights reserved.
//

class ImageAllSizesRepresentation {
    let imageID: String
    let original: ImageSizeRepresentation
    let large: ImageSizeRepresentation
    let medium: ImageSizeRepresentation
    let small: ImageSizeRepresentation
    let thumbnail: ImageSizeRepresentation
    
    init?(original: ImageSizeRepresentation,
          large: ImageSizeRepresentation,
          medium: ImageSizeRepresentation,
          small: ImageSizeRepresentation,
          thumbnail: ImageSizeRepresentation) {
        self.imageID = original.imageID
        self.original = original
        self.large = large
        self.medium = medium
        self.small = small
        self.thumbnail = thumbnail
        
        if  large.imageID != original.imageID ||
            medium.imageID != original.imageID ||
            small.imageID != original.imageID ||
            thumbnail.imageID != original.imageID {
            return nil
        }
        
    }
    
}
