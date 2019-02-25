//
//  UIButtonExtensions.swift
//  Pear
//
//  Created by Avery Lamp on 2/14/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation
import UIKit

typealias UIButtonTargetClosure = (UIButton) -> ()

class ClosureWrapper: NSObject {
    let closure: UIButtonTargetClosure
    init(_ closure: @escaping UIButtonTargetClosure) {
        self.closure = closure
    }
}

extension UIButton {
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIButtonTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addTargetClosure(closure: @escaping UIButtonTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIButton.closureAction), for: .touchUpInside)
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
    
    
    func stylizeDarkColor(){
        self.backgroundColor = Config.nextButtonColor
        self.layer.cornerRadius = self.frame.height / 2.0
        self.layer.shadowRadius = 1
        self.layer.shadowColor = UIColor(white: 0.0, alpha: 0.15).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1.0
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont(name: Config.textFontSemiBold, size: 17)
    }
    
    func stylizeLightColor(){
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = self.frame.height / 2.0
        self.layer.shadowRadius = 1
        self.layer.shadowColor = UIColor(white: 0.0, alpha: 0.15).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1.0
        self.setTitleColor(Config.textFontColor, for: .normal)
        self.titleLabel?.font = UIFont(name: Config.textFontSemiBold, size: 17)
    }
    

}
