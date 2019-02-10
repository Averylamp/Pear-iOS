//
//  GetStartedSampleBiosViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedSampleBiosViewController: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileCardView: UIView!
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> GetStartedSampleBiosViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedSampleBiosViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedSampleBiosViewController
        return vc
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - Life Cycle
extension GetStartedSampleBiosViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSampleProfiles()
    }
    
    
    func setupSampleProfiles(){
        let numProfiles = 5
        for i in 0..<numProfiles {
            let cardView = UIView(frame: CGRect(x: self.scrollView.frame.width * CGFloat(i) + 40, y: 0, width: self.scrollView.frame.width - 80, height: self.scrollView.frame.height))
            cardView.layer.shadowRadius = 3.0
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.3
            cardView.layer.shadowOffset = CGSize(width: 1, height: 1)
            cardView.layer.cornerRadius = 10
            cardView.addMotionEffect(MotionEffectGroupGenerator.getMotionEffectGroup(maxDistance: 10.0))
            self.scrollView.addSubview(cardView)
            
            let cardImageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: cardView.frame.size))
            cardImageView.image = UIImage(named: "onboarding-sample-profile")
            cardImageView.contentMode = .scaleAspectFit
            cardView.addSubview(cardImageView)
        }
        
        self.scrollView.isPagingEnabled = true
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * CGFloat(numProfiles), height: self.scrollView.frame.height)
    }
    
}
