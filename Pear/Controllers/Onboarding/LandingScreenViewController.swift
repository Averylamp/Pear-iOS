//
//  LandingScreenViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/8/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class LandingScreenViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> LandingScreenViewController {
        let storyboard = UIStoryboard(name: String(describing: LandingScreenViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! LandingScreenViewController
        return vc
    }

    
    
}


// MARK: - Life Cycle
extension LandingScreenViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleButtons()
        attachButtons()
        setupScrollView()
        
    }

}

// MARK: - Styling
extension LandingScreenViewController{
    func styleButtons(){
        signupButton.layer.shadowRadius = 3
        signupButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        signupButton.layer.shadowColor = UIColor.black.cgColor
        signupButton.layer.shadowOpacity = 0.4
        signupButton.layer.cornerRadius = 4
        
        loginButton.layer.shadowRadius = 3
        loginButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOpacity = 0.4
        loginButton.layer.cornerRadius = 4
    }
    
    func setupScrollView(){
        let numPages: Int  = 4
        scrollView.contentSize = CGSize(width: self.view!.frame.width * CGFloat(numPages), height: scrollView.frame.size.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        pageControl.numberOfPages = numPages
    }
    
    
}


// MARK: - @IBActions
private extension LandingScreenViewController{
    func attachButtons(){
        signupButton.addTarget(self, action: #selector(LandingScreenViewController.signupButtonClicked(sender:)), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(LandingScreenViewController.loginButtonClicked(sender:)), for: .touchUpInside)
    }
    
    @objc func signupButtonClicked(sender:UIButton){
        print("Signup Clicked")
    }
    
    @objc func loginButtonClicked(sender:UIButton){
        print("Login Clicked")
    }
    
    
}



