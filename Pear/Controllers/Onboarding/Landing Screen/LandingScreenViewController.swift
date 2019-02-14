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

    let pages: [LandingScreenPageViewController] = [LandingScreenPage1ViewController.instantiate(),
                                                    LandingScreenPage2ViewController.instantiate(),
                                                    LandingScreenPage3ViewController.instantiate(),
                                                    LandingScreenPage4ViewController.instantiate()]
    
}


// MARK: - Life Cycle
extension LandingScreenViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleButtons()
        attachButtons()
        setupScrollView()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        super.viewDidAppear(animated)
    }
}

// MARK: - Styling
extension LandingScreenViewController{
    func styleButtons(){
        signupButton.layer.shadowRadius = 1
        signupButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        signupButton.layer.shadowColor = UIColor.black.cgColor
        signupButton.layer.shadowOpacity = 0.4
        signupButton.layer.cornerRadius = 4
        signupButton.addMotionEffect(MotionEffectGroupGenerator.getMotionEffectGroup(maxDistance: 3.0))
        
        loginButton.layer.shadowRadius = 1
        loginButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOpacity = 0.4
        loginButton.layer.cornerRadius = 4
        loginButton.addMotionEffect(MotionEffectGroupGenerator.getMotionEffectGroup(maxDistance: 3.0))
    }
    
    func setupScrollView(){
        let numPages: Int  = 4
        scrollView.contentSize = CGSize(width: self.view!.frame.width * CGFloat(numPages), height: scrollView.frame.size.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        pageControl.numberOfPages = numPages
        pageControl.addTarget(self, action: #selector(LandingScreenViewController.pageControlChanged(sender:)), for: .valueChanged)
        
        for i in 0..<self.pages.count{
            self.addChild(self.pages[i])
            self.pages[i].view.frame = CGRect(x: CGFloat(i) * scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(self.pages[i].view)
            self.pages[i].didMove(toParent: self)
        }
        scrollView.delegate = self
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
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        let inputNameVC = GetStartedYourNameViewController.instantiate(gettingStartedData: GetttingStartedData.fakeData())
        self.navigationController?.pushViewController(inputNameVC, animated: true)
    }
    
    @objc func loginButtonClicked(sender:UIButton){
        print("Login Clicked")
    }
    
    @objc func pageControlChanged(sender: UIPageControl){
        let pageIndex:Int = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        if sender.currentPage != pageIndex{
            scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.width * CGFloat(sender.currentPage), y: 0), animated: true)
        }
    }
}


// MARK: - UIScrollViewDelegate
extension LandingScreenViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        let percentOffset: CGFloat = scrollView.contentOffset.x / scrollView.contentSize.width
        
        let scaleSize: CGFloat = 0.6
        if(percentOffset > 0 && percentOffset <= 0.25) {
            pages[0].scaleImageView(percent: 1 - ((percentOffset) * 4 * scaleSize))
            pages[1].scaleImageView(percent: (1 - scaleSize) + ((percentOffset) * 4 * scaleSize))
        } else if(percentOffset > 0.25 && percentOffset <= 0.50) {
            pages[1].scaleImageView(percent: 1.0 - ((percentOffset - 0.25) * 4 * scaleSize))
            pages[2].scaleImageView(percent: (1 - scaleSize) + ((percentOffset - 0.25) * 4 * scaleSize))
        } else if(percentOffset > 0.50 && percentOffset <= 0.75) {
            pages[2].scaleImageView(percent: 1.0 - ((percentOffset - 0.5) * 4 * scaleSize))
            pages[3].scaleImageView(percent: (1 - scaleSize) + ((percentOffset - 0.5) * 4 * scaleSize))
        }else if(percentOffset > 0.75 && percentOffset <= 1) {
            pages[3].scaleImageView(percent: 1.0 - ((percentOffset - 0.75) * 4 * scaleSize))
        }
    }
    
}
