//
//  Config.swift
//  Pear
//
//  Created by Avery Lamp on 2/11/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation
import UIKit

class Config {
    
    static let shouldSkipLogin: Bool = false
    
    static let devGraphQLHost: URL = URL(string: "http://66.31.16.203:1234/graphql")!
    static let graphQLHost: URL = URL(string: "http://66.31.16.203:1234/graphql")!
    static let imageAPIHost: URL = URL(string: "http://koala.mit.edu:1337")!
    
    static let logoFont: String = "FredokaOne-Regular"
    
    static let displayFontRegular: String = "SFProDisplay-Regular"
    static let displayFontLight: String = "SFProDisplay-Light"
    static let displayFontMedium: String = "SFProDisplay-Medium"
    
    static let textFontRegular: String = "Nunito-Regular"
    static let textFontBlack: String = "Nunito-Black"
    static let textFontBold: String = "Nunito-Bold"
    static let textFontExtraBold: String = "Nunito-ExtraBold"
    static let textFontExtraLight: String = "Nunito-ExtraLight"
    static let textFontLight: String = "Nunito-Light"
    static let textFontSemiBold: String = "Nunito-SemiBold"
    static let textFontColor: UIColor = UIColor(red: 0.27, green: 0.29, blue: 0.33, alpha: 1.00)
    
    static let inactiveTextFontColor: UIColor = UIColor(red: 0.27, green: 0.29, blue: 0.33, alpha: 0.3)
    
    static let nextButtonColor: UIColor = UIColor(red: 0.27, green: 0.29, blue: 0.33, alpha: 1.00)
    
    static let totalGettingStartedPagesNumber: CGFloat = 7.0
    static let progressBarAnimationDuration: Double = 0.4
    static let progressBarAnimationDelay: Double = 0.0
    
}
