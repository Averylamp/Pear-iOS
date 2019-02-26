
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
    
    @IBOutlet weak var textLengthLabel: UILabel!
    @IBOutlet weak var inputTextView: UITextView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
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
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
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
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
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
        self.inputTextView.isScrollEnabled = true
        
        if self.gettingStartedData.profileData.shortBio != "" {
            self.inputTextView.text = self.gettingStartedData.profileData.shortBio
            textViewDidChange(self.inputTextView)
        }
        
        self.updateTextLabels()
        self.addDismissKeyboardOnViewClick()
        self.addKeyboardSizeNotifications()
        self.stylize()
    }
    
    func stylize(){
        self.nextButton.stylizeDarkColor()
        self.titleLabel.stylizeTitleLabel()
        self.subtitleLabel.stylizeSubtitleLabelSmall()
        
        self.inputTextView.layer.borderColor = Config.textFontColor.cgColor
        self.inputTextView.layer.borderWidth = 1
        self.inputTextView.layer.cornerRadius = 15
        self.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.inputTextView.font = UIFont(name: Config.displayFontRegular, size: 17)
        self.inputTextView.textColor = Config.textFontColor
    }
    
    func addDismissKeyboardOnViewClick(){
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GetStartedShortBioViewController.dismissKeyboard)))
    }
    
    @objc func dismissKeyboard(){
        self.inputTextView.resignFirstResponder()
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
    
    func updateTextLabels(){
        self.textLengthLabel.text = "\(self.inputTextView.text.count) / \(maxTextLength)"
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.updateTextLabels()
    }
    
}


// MARK: - Keybaord Size Notifications
extension GetStartedShortBioViewController{
    
    func addKeyboardSizeNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedShortBioViewController.keyboardWillChange(notification:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedShortBioViewController.keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillChange(notification: Notification){
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let bottomSpacing: CGFloat = 20
        self.nextButtonBottomConstraint.constant = targetFrame.size.height - self.view.safeAreaInsets.bottom + bottomSpacing
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification){
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.nextButtonBottomConstraint.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
}
