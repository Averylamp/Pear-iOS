//
//  ImageAllSizesRepresentation.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 sam. All rights reserved.
//



class ImageAllSizesRepresentation{
    let original: ImageSizeRepresentation
    let large: ImageSizeRepresentation
    let medium: ImageSizeRepresentation
    let small: ImageSizeRepresentation
    let thumbnail: ImageSizeRepresentation
    
    init(original: ImageSizeRepresentation,
        large: ImageSizeRepresentation,
        medium: ImageSizeRepresentation,
        small: ImageSizeRepresentation,
        thumbnail: ImageSizeRepresentation) {
        self.original = original
        self.large = large
        self.medium = medium
        self.small = small
        self.thumbnail = thumbnail
    }
    
}

