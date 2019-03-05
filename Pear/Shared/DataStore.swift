//
//  DataStore.swift
//  Pear
//
//  Created by Avery Lamp on 3/5/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation

class DataStore {
    
    static let shared = DataStore()
    
    var currentPearUser: PearUser?
    
    private init() {
        
    }

}
