
//
//  GetStartedDoDontViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/11/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedDoDontViewController: UIViewController {
    
    var gettingStartedData: GetttingStartedData!
        
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var samplesButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var samplesButton: UIButton!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    let doDontTitleHeight: CGFloat = 34
    
    @IBOutlet weak var stackView: UIStackView!
    
    let sampleStarters: [String] = [
        "Ask about ...",
        "Talk about ...",
        "Say something about ...",
        "Comment on ...",
        "Tell them ...",
        "Pretend to ...",
        "Give them ...",
    ]
    
    var doTextViewControllers: [ExpandingTextViewController] = []
    var dontTextViewControllers: [ExpandingTextViewController] = []
    
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GetttingStartedData) -> GetStartedDoDontViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedDoDontViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedDoDontViewController
        vc.gettingStartedData = gettingStartedData
        return vc
    }
    
    func saveDoDontListsTo(gettingStartedData: GetttingStartedData){
        gettingStartedData.doList = []
        gettingStartedData.dontList = []
        for doTVC in self.doTextViewControllers {
            if doTVC.textView.text.count >= 3 && !self.sampleStarters.contains(doTVC.textView.text) {
                gettingStartedData.doList.append(doTVC.textView.text)
            }
        }
        for dontTVC in self.dontTextViewControllers {
            if dontTVC.textView.text.count >= 3 && !self.sampleStarters.contains(dontTVC.textView.text) {
                gettingStartedData.dontList.append(dontTVC.textView.text)
            }
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        saveDoDontListsTo(gettingStartedData: self.gettingStartedData)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        saveDoDontListsTo(gettingStartedData: self.gettingStartedData)
        let createAccountVC = GetStartedCreateAccountViewController.instantiate(gettingStartedData: self.gettingStartedData)
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
        
        self.addDoDontGroup()
        self.addKeyboardSizeNotifications()
        self.addDismissKeyboardOnViewClick()
        self.restoreSavedState()
    }
    
    func populateTVCWithText(text: String, tvc: ExpandingTextViewController){
        tvc.textViewDidBeginEditing(tvc.textView)
        tvc.textView.text = text
        tvc.textViewDidChange(tvc.textView)
        tvc.removeAllAccessoryButtons()
        tvc.addAccessoryButton(image: UIImage(named: "onboarding-icon-close")!, buttonType: .close)
    }
    
    func restoreSavedState(){
        for doText in self.gettingStartedData.doList{
            if let lastTVC = self.doTextViewControllers.last, lastTVC.textView.text.count == 0 || self.sampleStarters.contains(lastTVC.textView.text){
                populateTVCWithText(text: doText, tvc: lastTVC)
                self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .doType)
            }else{
                self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .doType)
                let lastTVC = self.doTextViewControllers.last!
                populateTVCWithText(text: doText, tvc: lastTVC)
            }
        }
        for dontText in self.gettingStartedData.dontList{
            if let lastTVC = self.dontTextViewControllers.last, lastTVC.textView.text.count == 0 || self.sampleStarters.contains(lastTVC.textView.text) {
                populateTVCWithText(text: dontText, tvc: lastTVC)
                self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .dontType)
            }else{
                self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .dontType)
                let lastTVC = self.dontTextViewControllers.last!
                populateTVCWithText(text: dontText, tvc: lastTVC)
            }
        }
    }
    
    func addDismissKeyboardOnViewClick(){
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GetStartedDoDontViewController.dismissKeyboard)))
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func addKeyboardSizeNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedDoDontViewController.keyboardWillChange(notification:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedDoDontViewController.keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    enum DoType {
        case doType
        case dontType
    }

    func addTitleLabelToStackView(stackView: UIStackView, type: DoType) {
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
        
        stackView.addArrangedSubview(titleView)
        stackView.addConstraints([
            NSLayoutConstraint(item: titleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: doDontTitleHeight),
            NSLayoutConstraint(item: titleView, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0)
        ])
        
    }
    
    func addExpandingTextViewControllerToStackView(stackView: UIStackView, type: DoType){
        
        let expandingTextViewVC = ExpandingTextViewController.instantiate()
        expandingTextViewVC.delegate = self
        self.addChild(expandingTextViewVC)
        if type == .doType{
            expandingTextViewVC.tag = doTextViewControllers.count
            self.stackView.insertArrangedSubview(expandingTextViewVC.view, at: 2 + self.doTextViewControllers.count)
            doTextViewControllers.append(expandingTextViewVC)
        }else{
            expandingTextViewVC.tag = dontTextViewControllers.count
            dontTextViewControllers.append(expandingTextViewVC)
            self.stackView.addArrangedSubview(expandingTextViewVC.view)
        }
        let initialHeight: CGFloat = 42
        expandingTextViewVC.minTextViewSize = initialHeight
        let expandingTextViewHeightConstraint = NSLayoutConstraint(item: expandingTextViewVC.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: initialHeight)
        
        self.stackView.addConstraints([
            expandingTextViewHeightConstraint,
            NSLayoutConstraint(item: expandingTextViewVC.view, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0)
            ])
        
        expandingTextViewVC.animationDuration = 0.1
        
        expandingTextViewVC.textView.font = UIFont.systemFont(ofSize: 18)
        expandingTextViewVC.textView.isScrollEnabled = false
        expandingTextViewVC.textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 8)
        expandingTextViewVC.textView.tintColor = UIColor.darkGray
        
        expandingTextViewVC.viewHeightConstraint = expandingTextViewHeightConstraint
        expandingTextViewVC.didMove(toParent: self)
        
        let segmentView = UIView()
        segmentView.translatesAutoresizingMaskIntoConstraints = false
        segmentView.backgroundColor = UIColor(white: 0.4, alpha: 0.2)
        expandingTextViewVC.view.addSubview(segmentView)
        expandingTextViewVC.view.addConstraints([
            NSLayoutConstraint(item: segmentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0),
            NSLayoutConstraint(item: segmentView, attribute: .width, relatedBy: .equal, toItem: expandingTextViewVC.view, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: segmentView, attribute: .centerX, relatedBy: .equal, toItem: expandingTextViewVC.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: segmentView, attribute: .bottom, relatedBy: .equal, toItem: expandingTextViewVC.view, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            ])
        
        expandingTextViewVC.setPlaceholderText(text: self.sampleStarters[(self.doTextViewControllers.count + self.dontTextViewControllers.count) % self.sampleStarters.count])
    }
    
    func addDoDontGroup(){
        self.addTitleLabelToStackView(stackView: self.stackView, type: .doType)
        self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .doType)
        self.addTitleLabelToStackView(stackView: self.stackView, type: .dontType)
        self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .dontType)
    }
    
}

// Mark: - Expanding Text VC Delegate
extension GetStartedDoDontViewController: ExpandingTextViewControllerDelegate {
    func primaryAccessoryButtonPressed(expandingTextViewController: ExpandingTextViewController, sender: UIButton) {
        
        if sender.tag == 0{
            // Add clicked
            if self.doTextViewControllers.contains(expandingTextViewController){
                self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .doType)
            }else if self.dontTextViewControllers.contains(expandingTextViewController){
                self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .dontType)
            }
            expandingTextViewController.removeAllAccessoryButtons()
            expandingTextViewController.addAccessoryButton(image: UIImage(named: "onboarding-icon-close")!, buttonType: .close)
            expandingTextViewController.textViewDidChange(expandingTextViewController.textView)
            self.returnKeyPressed(expandingTextViewController: expandingTextViewController)
        }else if sender.tag == 1{
            // Clear case
            if self.doTextViewControllers.contains(expandingTextViewController){
                if self.doTextViewControllers.count == 1 {
                    expandingTextViewController.textView.text = ""
                }else{
                    if self.doTextViewControllers.last == expandingTextViewController {
                        self.resetButtonsAddClose(expandingTextVC: self.doTextViewControllers[self.doTextViewControllers.count - 2])
                    }
                    
                    self.stackView.removeArrangedSubview(expandingTextViewController.view)
                    expandingTextViewController.view.removeFromSuperview()
                    if let index = self.doTextViewControllers.firstIndex(of: expandingTextViewController){
                        self.doTextViewControllers.remove(at: index)
                    }
                }
            }else if self.dontTextViewControllers.contains(expandingTextViewController){
                if self.dontTextViewControllers.count == 1 {
                    expandingTextViewController.textView.text = ""
                }else{
                    if self.dontTextViewControllers.last == expandingTextViewController {
                        self.resetButtonsAddClose(expandingTextVC: self.dontTextViewControllers[self.dontTextViewControllers.count - 2])
                    }
                    
                    self.stackView.removeArrangedSubview(expandingTextViewController.view)
                    expandingTextViewController.view.removeFromSuperview()
                    if let index = self.dontTextViewControllers.firstIndex(of: expandingTextViewController){
                        self.dontTextViewControllers.remove(at: index)
                    }
                }
            }
            
        }
    }
    
    func resetButtonsAddClose(expandingTextVC: ExpandingTextViewController){
        expandingTextVC.removeAllAccessoryButtons()
        expandingTextVC.addAccessoryButton(image: UIImage(named: "onboarding-icon-plus")!, buttonType: .add)
        expandingTextVC.addAccessoryButton(image: UIImage(named: "onboarding-icon-close")!, buttonType: .close)
    }
    
    func seccondaryAccessoryButtonPressed(expandingTextViewController: ExpandingTextViewController, sender: UIButton) {
        if sender.tag == 1 {
            if self.doTextViewControllers.contains(expandingTextViewController){
                if self.doTextViewControllers.count > 1 {
                    if self.doTextViewControllers.last == expandingTextViewController {
                        self.resetButtonsAddClose(expandingTextVC: self.doTextViewControllers[self.doTextViewControllers.count - 2])
                    }
                    
                    self.stackView.removeArrangedSubview(expandingTextViewController.view)
                    expandingTextViewController.view.removeFromSuperview()
                    if let index = self.doTextViewControllers.firstIndex(of: expandingTextViewController){
                        self.doTextViewControllers.remove(at: index)
                    }
                }else{
                    expandingTextViewController.textView.text = ""
                }
            }else if self.dontTextViewControllers.contains(expandingTextViewController){
                if self.dontTextViewControllers.count > 1 {
                    if self.dontTextViewControllers.last == expandingTextViewController {
                        self.resetButtonsAddClose(expandingTextVC: self.dontTextViewControllers[self.dontTextViewControllers.count - 2])
                    }
                    
                    self.stackView.removeArrangedSubview(expandingTextViewController.view)
                    expandingTextViewController.view.removeFromSuperview()
                    if let index = self.dontTextViewControllers.firstIndex(of: expandingTextViewController){
                        self.dontTextViewControllers.remove(at: index)
                    }
                }else{
                    expandingTextViewController.textView.text = ""
                }
            }
        }
    }
    
    
    func textViewDidChange(expandingTextViewController: ExpandingTextViewController) {
        if expandingTextViewController.textView.text.count > 0  &&
            (expandingTextViewController == self.doTextViewControllers.last || expandingTextViewController == self.dontTextViewControllers.last) &&
            expandingTextViewController.primaryAccessoryButton == nil
            {
            expandingTextViewController.addAccessoryButton(image: UIImage(named: "onboarding-icon-plus")!, buttonType: .add)
            expandingTextViewController.addAccessoryButton(image: UIImage(named: "onboarding-icon-close")!, buttonType: .close)
        }
    }
    
    func returnKeyPressed(expandingTextViewController: ExpandingTextViewController) {
        var nextTextView: UITextView?
        
        if self.doTextViewControllers.contains(expandingTextViewController), let index = self.doTextViewControllers.firstIndex(of: expandingTextViewController){
            if index < self.doTextViewControllers.count - 1 {
                nextTextView = self.doTextViewControllers[index + 1].textView
            }else if self.dontTextViewControllers.count > 0{
                nextTextView = self.dontTextViewControllers[0].textView
            }
        }else if self.dontTextViewControllers.contains(expandingTextViewController),let index = self.dontTextViewControllers.firstIndex(of: expandingTextViewController){
            if index < self.dontTextViewControllers.count - 1{
                nextTextView = self.dontTextViewControllers[index + 1].textView
            }
        }
        if let nextTextView = nextTextView {
            nextTextView.becomeFirstResponder()
            self.scrollView.scrollRectToVisible(nextTextView.superview!.frame, animated: true)
        }else {
            expandingTextViewController.textView.resignFirstResponder()
        }
    }
    
}


// MARK: - Keybaord Size Notifications
extension GetStartedDoDontViewController{
    
    @objc func keyboardWillChange(notification: Notification){
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.scrollViewBottomConstraint.constant = targetFrame.size.height - self.view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func keyboardWillHide(notification: Notification){
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.scrollViewBottomConstraint.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}
