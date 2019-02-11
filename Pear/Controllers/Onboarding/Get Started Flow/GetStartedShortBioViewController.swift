
//
//  GetStartedShortBioViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedShortBioViewController: UIViewController {
    
    var endorsement: Endorsement!
    
    @IBOutlet weak var inputTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLengthLabel: UILabel!
    
    @IBOutlet weak var samplesButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputTextView: UITextView!
    
    @IBOutlet weak var samplesButton: UIButton!
    let maxTextLength: Int = 600
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(endorsement: Endorsement) -> GetStartedShortBioViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedShortBioViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedShortBioViewController
        vc.endorsement = endorsement
        return vc
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        
        let photoInputVC = GetStartedDoDontViewController.instantiate(endorsement: self.endorsement)
        self.navigationController?.pushViewController(photoInputVC, animated: true)
        
    }
    
    
    @IBAction func sampleButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        let sampleBiosVC = GetStartedSampleBiosViewController.instantiate()
        self.present(sampleBiosVC, animated: true, completion: nil)
    }
    
    
}


// MARK: - Life Cycle
extension GetStartedShortBioViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputTextView.delegate = self
        self.inputTextView.becomeFirstResponder()
        self.inputTextView.textContainerInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.inputTextView.isScrollEnabled = false
        
        self.textLengthLabel.text = "\(self.inputTextView.text.count) / \(maxTextLength)"
        
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
    }
    
}

// MARK: - UITextView Delegate
extension GetStartedShortBioViewController:UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count + text.count - range.length > maxTextLength {
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.textLengthLabel.text = "\(textView.text.count) / \(maxTextLength)"
        let textHeight = self.inputTextView.sizeThatFits(CGSize(width: self.inputTextView.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
        let textPadding: CGFloat = 8.0
        inputTextViewHeightConstraint.constant = max(34, textPadding + textHeight)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
}
