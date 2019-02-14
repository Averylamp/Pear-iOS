
//
//  GetStartedShortBioViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedShortBioViewController: UIViewController {
    
    var gettingStartedData: GetttingStartedData!
    
    @IBOutlet weak var inputTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLengthLabel: UILabel!
    
    @IBOutlet weak var samplesButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputTextView: UITextView!
    
    @IBOutlet weak var samplesButton: UIButton!
    let maxTextLength: Int = 600
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GetttingStartedData) -> GetStartedShortBioViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedShortBioViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedShortBioViewController
        vc.gettingStartedData = gettingStartedData
        return vc
    }
    
    func saveBio(){
        self.gettingStartedData.profileData.shortBio = inputTextView.text
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.saveBio()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        self.saveBio()
        if self.gettingStartedData.profileData.shortBio.count < 50 {
            let alertController = UIAlertController(title: nil, message: "Your bio seems a little short 🤔.  Don't you think your friend deserves a little more?", preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "Yeah, I'll help 'em out", style: .cancel, handler: nil)
            let continueButton = UIAlertAction(title: "Continue anyway", style: .default) { (action) in
                let photoInputVC = GetStartedDoDontViewController.instantiate(gettingStartedData: self.gettingStartedData)
                self.navigationController?.pushViewController(photoInputVC, animated: true)
            }
            
            alertController.addAction(cancelButton)
            alertController.addAction(continueButton)
            self.present(alertController, animated: true, completion: nil)
            return

        }
        
        let photoInputVC = GetStartedDoDontViewController.instantiate(gettingStartedData: self.gettingStartedData)
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
        self.samplesButton.layer.borderColor = UIColor(red:0.07, green:0.07, blue:0.07, alpha:0.1).cgColor
        self.samplesButton.layer.cornerRadius = 20.0
        self.view.layoutIfNeeded()
        let titleWidth = self.samplesButton.titleLabel!.frame.width
        let starsImage = UIImage(named: "onboarding-icon-samples-stars")
        self.samplesButton.setImage(starsImage?.imageWith(newSize: CGSize(width: 20, height: 20)), for: .normal)
        self.samplesButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 8)
        self.samplesButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        let imageWidth = self.samplesButton.imageView!.frame.width
        let fullSamplesButtonWidth: CGFloat = titleWidth + imageWidth + 40
        self.samplesButtonWidthConstraint.constant = fullSamplesButtonWidth
        self.view.layoutIfNeeded()
        self.samplesButton.addMotionEffect(MotionEffectGroupGenerator.getMotionEffectGroup(maxDistance: 3.0))
        
        if self.gettingStartedData.profileData.shortBio != "" {
            self.inputTextView.text = self.gettingStartedData.profileData.shortBio
            textViewDidChange(self.inputTextView)
        }
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
