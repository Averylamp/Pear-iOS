
//
//  GetStartedDoDontViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/11/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedDoDontViewController: UIViewController {
    
    var endorsement: Endorsement!
        
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var samplesButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var samplesButton: UIButton!
    
    let doDontTitleHeight: CGFloat = 34
    
    @IBOutlet weak var stackView: UIStackView!
    
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(endorsement: Endorsement) -> GetStartedDoDontViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedDoDontViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedDoDontViewController
        vc.endorsement = endorsement
        return vc
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        
        let createAccountVC = GetStartedCreateAccountViewController.instantiate(endorsement: self.endorsement)
        self.navigationController?.pushViewController(createAccountVC, animated: true)
        
    }
    
    
    @IBAction func sampleButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        let sampleBiosVC = GetStartedSampleBiosViewController.instantiate()
        self.present(sampleBiosVC, animated: true, completion: nil)
    }
    
    
}


// MARK: - Life Cycle
extension GetStartedDoDontViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.samplesButton.layer.borderWidth = 1
        self.samplesButton.layer.borderColor = UIColor(red:0.07, green:0.07, blue:0.07, alpha:1.00).cgColor
        self.samplesButton.layer.cornerRadius = 20.0
        self.view.layoutIfNeeded()
        let titleWidth = self.samplesButton.titleLabel!.frame.width
        let starsImage = UIImage(named: "onboarding-icon-samples-stars")
        self.samplesButton.setImage(starsImage?.imageWith(newSize: CGSize(width: 20, height: 20)), for: .normal)
        self.samplesButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 8)
        self.samplesButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        let imageWidth = self.samplesButton.imageView!.frame.width
        let fullSamplesButtonWidth: CGFloat = titleWidth + imageWidth + 40
        print("Width: \(fullSamplesButtonWidth)")
        self.samplesButtonWidthConstraint.constant = fullSamplesButtonWidth
        self.view.layoutIfNeeded()
        self.samplesButton.addMotionEffect(MotionEffectGroupGenerator.getMotionEffectGroup(maxDistance: 3.0))
        
        for i in 0...20{t
            self.addDoDontGroup()
        }
    }
    
    enum DoType {
        case doType
        case dontType
    }

    
    func generateTitleLabel(type: DoType) -> UIView {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: self.stackView.frame.width, height: 34))
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        let thumbImageView = UIImageView(frame: CGRect(x: 20, y: 4, width: 26, height: 26))
        if type == .doType{
            thumbImageView.image = UIImage(named: "onboarding-icon-thumb-do")
        }else{
            thumbImageView.image = UIImage(named: "onboarding-icon-thumb-dont")
        }
        thumbImageView.contentMode = .scaleAspectFit
        titleView.addSubview(thumbImageView)
        
        let textLabel = UILabel(frame: CGRect(x: 50, y: 0, width: titleView.frame.width - 60, height: titleView.frame.height))
        textLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        if type == .doType{
            textLabel.text = "Do..."
        }else{
            textLabel.text = "Don't..."
        }
        
        titleView.addSubview(textLabel)
        return titleView
    }
    
    
    
    
    func addDoDontGroup(){
        let doTitleView = generateTitleLabel(type: .doType)
        self.stackView.addArrangedSubview(doTitleView)
        self.stackView.addConstraints([
                NSLayoutConstraint(item: doTitleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: doDontTitleHeight),
                NSLayoutConstraint(item: doTitleView, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0)
            ])
        
        
        
        let dontTitleView = generateTitleLabel(type: .dontType)
        self.stackView.addArrangedSubview(dontTitleView)
        self.stackView.addConstraints([
            NSLayoutConstraint(item: dontTitleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: doDontTitleHeight),
            NSLayoutConstraint(item: dontTitleView, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0)
            ])
        
    }
    
    func removeLastDoDontGroup(){
        
        
    }
}
