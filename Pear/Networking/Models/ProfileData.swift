//
//  ProfileData.swift
//  Pear
//
//  Created by Avery Lamp on 2/13/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation
import UIKit

class ProfileData {
    
    let firstName: String
    let lastName: String
    let fullName: String
    let age: Int
    let interests: [String]
    let shortBio: String
    let doList: [String]
    let dontList: [String]
    let imageURLs: [URL]
    let images: [UIImage]
    
    init(gettingStartedData: GetttingStartedData){
        firstName = ""
        lastName = ""
        fullName = ""
        age = 19
        interests = []
        shortBio = ""
        doList = []
        dontList = []
        imageURLs = []
        images = []
        
    }
    
    
    
    
    
}
