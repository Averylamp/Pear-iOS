
//
//  GetStartedInterestsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedInterestsViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var endorsement: Endorsement!
    
    let interestStrings: [String] = [
        "Language",
        "Pets",
        "Nature",
        "Poetry",
        "Adventure",
        "Climate",
        "Handicraft",
        "Vegan",
        "Writing",
        "Anime",
        "Philosophy",
        "Magic",
        "Storytelling",
        "News",
        "Law",
        "Sustainability",
        "Beauty",
        "Makeup",
        "Sci-Fi",
        "Deaf",
        "Coding",
        "Fantasy",
        "DIY",
        "Board Games",
        "Environment",
        "Illustration",
        "Design",
        "Technology",
        "Music",
        "Gaming",
        "Fasion",
        "Movies",
        "Cars"
    ]
    
    var interestButtons: [UIButton] = []
    
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(endorsement: Endorsement) -> GetStartedInterestsViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedInterestsViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedInterestsViewController
        vc.endorsement = endorsement
        return vc
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        for button in self.interestButtons{
            self.endorsement.interests = []
            if button.isSelected{
                self.endorsement.interests.append(button.titleLabel!.text!)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        for button in self.interestButtons{
            self.endorsement.interests = []
            if button.isSelected{
                self.endorsement.interests.append(button.titleLabel!.text!)
            }
        }
        
    }
    
}


// MARK: - Life Cycle
extension GetStartedInterestsViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterestButtons()
        // Do any additional setup after loading the view.
    }
    
    
    func setupInterestButtons(){
        let numRows = Int(ceil(Double(interestStrings.count) / 3.0))
        let sideOffset: CGFloat = 25
        let buttonSpacing: CGFloat = 8
        let buttonHeight: CGFloat = 40
        let rowHeight = buttonHeight + buttonSpacing
        let buttonWidth = (self.scrollView.frame.width - (2 * sideOffset + 2 * buttonSpacing)) / 3
        for i in 0..<numRows{
            let leftButton  = UIButton()
            leftButton.addTarget(self, action: #selector(GetStartedInterestsViewController.interestButtonClicked(sender:)), for: .touchUpInside)
            self.scrollView.addSubview(leftButton)
            leftButton.setTitle(interestStrings[i * 3], for: .normal)
            leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            leftButton.titleLabel?.minimumScaleFactor = 0.5
            leftButton.titleLabel?.adjustsFontSizeToFitWidth = true
            leftButton.frame = CGRect(x: sideOffset, y: buttonSpacing + rowHeight * CGFloat(i), width: buttonWidth, height: buttonHeight)
            leftButton.backgroundColor = UIColor(red:0.95, green:0.96, blue:0.95, alpha:1.00)
            leftButton.layer.cornerRadius = buttonHeight / 2.0
            leftButton.setTitleColor(UIColor(red:0.31, green:0.31, blue:0.31, alpha:1.00), for: .normal)
            leftButton.setTitleColor(UIColor(red:0.00, green:0.75, blue:0.44, alpha:1.00), for: .selected)
            leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            self.interestButtons.append(leftButton)
            
            
            if (i * 3 + 1 < interestStrings.count){
                let centerButton  = UIButton()
                centerButton.addTarget(self, action: #selector(GetStartedInterestsViewController.interestButtonClicked(sender:)), for: .touchUpInside)
                self.scrollView.addSubview(centerButton)
                centerButton.setTitle(interestStrings[i * 3 + 1], for: .normal)
                centerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
                centerButton.frame = CGRect(x: sideOffset + (buttonWidth + buttonSpacing), y: buttonSpacing + rowHeight * CGFloat(i), width: buttonWidth, height: buttonHeight)
                centerButton.titleLabel?.minimumScaleFactor = 0.5
                centerButton.titleLabel?.adjustsFontSizeToFitWidth = true
                centerButton.backgroundColor = UIColor(red:0.95, green:0.96, blue:0.95, alpha:1.00)
                centerButton.layer.cornerRadius = buttonHeight / 2.0
                centerButton.setTitleColor(UIColor(red:0.31, green:0.31, blue:0.31, alpha:1.00), for: .normal)
                centerButton.setTitleColor(UIColor(red:0.00, green:0.75, blue:0.44, alpha:1.00), for: .selected)
                centerButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
                self.interestButtons.append(centerButton)
            }
            
            if (i * 3 + 2 < interestStrings.count){
                let rightButton  = UIButton()
                rightButton.addTarget(self, action: #selector(GetStartedInterestsViewController.interestButtonClicked(sender:)), for: .touchUpInside)
                self.scrollView.addSubview(rightButton)
                rightButton.setTitle(interestStrings[i * 3 + 2], for: .normal)
                rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
                rightButton.frame = CGRect(x: sideOffset + (buttonWidth + buttonSpacing) * 2, y: buttonSpacing + rowHeight * CGFloat(i), width: buttonWidth, height: buttonHeight)
                rightButton.titleLabel?.minimumScaleFactor = 0.5
                rightButton.titleLabel?.adjustsFontSizeToFitWidth = true
                rightButton.backgroundColor = UIColor(red:0.95, green:0.96, blue:0.95, alpha:1.00)
                rightButton.layer.cornerRadius = buttonHeight / 2.0
                rightButton.setTitleColor(UIColor(red:0.31, green:0.31, blue:0.31, alpha:1.00), for: .normal)
                rightButton.setTitleColor(UIColor(red:0.00, green:0.75, blue:0.44, alpha:1.00), for: .selected)
                rightButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
                self.interestButtons.append(rightButton)
            }
            
        }
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: rowHeight * CGFloat(numRows) + 2.0 * buttonSpacing)
        
        for button in self.interestButtons{
            if self.endorsement.interests.contains(button.titleLabel!.text!){
                self.interestButtonClicked(sender: button)
            }
        }
        
    }
    
    @objc func interestButtonClicked(sender: UIButton){
        if sender.isSelected {
            sender.isSelected = false
            sender.backgroundColor = UIColor(red:0.95, green:0.96, blue:0.95, alpha:1.00)
            sender.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        }else{
            sender.isSelected = true
            sender.backgroundColor = UIColor(red:0.84, green:0.98, blue:0.93, alpha:1.00)
            sender.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
    }
    
}
