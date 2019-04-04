//
//  GetStartedDoDontViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/11/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase

class GetStartedDoDontViewController: UIViewController {
  
  var gettingStartedData: UserProfileCreationData!
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
  let pageNumber: CGFloat = 5.0
  
  let doDontTitleHeight: CGFloat = 34
  let keyboardBottomPadding: CGFloat = 10
  
  @IBOutlet weak var stackView: UIStackView!
  
  let sampleStarters: [String] = [
    "..."
  ]
  
  var doTextViewControllers: [ExpandingTextViewController] = []
  var dontTextViewControllers: [ExpandingTextViewController] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedData: UserProfileCreationData) -> GetStartedDoDontViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedDoDontViewController.self), bundle: nil)
    guard let doDontVC = storyboard.instantiateInitialViewController() as? GetStartedDoDontViewController else { return nil }
    doDontVC.gettingStartedData = gettingStartedData
    return doDontVC
  }
  
  func saveDoDontListsTo(gettingStartedData: UserProfileCreationData) {
    gettingStartedData.dos = []
    gettingStartedData.donts = []
    for doTVC in self.doTextViewControllers {
      if doTVC.textView.text.count >= 3 && !self.sampleStarters.contains(doTVC.textView.text) {
        gettingStartedData.dos.append(doTVC.textView.text)
      }
    }
    for dontTVC in self.dontTextViewControllers {
      if dontTVC.textView.text.count >= 3 && !self.sampleStarters.contains(dontTVC.textView.text) {
        gettingStartedData.donts.append(dontTVC.textView.text)
      }
    }
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    let alertController = UIAlertController(title: "Stop Making a Profile?", message: "Are you sure you want to cancel", preferredStyle: .alert)
    let continueAction = UIAlertAction(title: "Keep Going", style: .default, handler: nil)
    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
      DispatchQueue.main.async {
        guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
          print("Failed to initialize Main VC")
          return
        }
        self.navigationController?.setViewControllers([mainVC], animated: true)
      }
    }
    alertController.addAction(continueAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    Analytics.logEvent("clicked_friend_dosdonts_back", parameters: nil)
    saveDoDontListsTo(gettingStartedData: self.gettingStartedData)
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    Analytics.logEvent("finished_friend_dosdonts", parameters: nil)
    saveDoDontListsTo(gettingStartedData: self.gettingStartedData)
    if self.gettingStartedData.dos.count + self.gettingStartedData.donts.count == 0 {
      self.alert(title: "Incomplete Field", message: "Please add either a Do or Don't for your friend")
      return
    }
    guard let shortBioVC = GetStartedShortBioViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
      print("Failed to create short Bio VC")
      return
    }
    self.navigationController?.pushViewController(shortBioVC, animated: true)
    
  }
  
  @IBAction func sampleButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let sampleBiosVC = GetStartedSampleBiosViewController.instantiate() else {
      print("Failed to createt Sample Bios VC")
      return
    }
    self.present(sampleBiosVC, animated: true, completion: nil)
  }
  
}

// MARK: - Life Cycle
extension GetStartedDoDontViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.addDoDontGroup()
    self.addKeyboardSizeNotifications()
    self.addDismissKeyboardOnViewClick()
    self.restoreSavedState()
    self.stylize()

  }
  
  func stylize() {
    self.nextButton.stylizeDark()
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabelSmall()
    
    self.progressWidthConstraint.constant = (pageNumber - 1) / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
    self.view.layoutIfNeeded()
    self.doTextViewControllers.first?.becomeFirstResponder()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self

    self.view.layoutIfNeeded()
    self.progressWidthConstraint.constant = pageNumber / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
    UIView.animate(withDuration: StylingConfig.progressBarAnimationDuration, delay: StylingConfig.progressBarAnimationDelay, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  func populateTVCWithText(text: String, tvc: ExpandingTextViewController) {
    tvc.textViewDidBeginEditing(tvc.textView)
    tvc.textView.text = text
    tvc.textViewDidChange(tvc.textView)
    tvc.removeAllAccessoryButtons()
    tvc.addAccessoryButton(image: UIImage(named: "onboarding-icon-close")!, buttonType: .close)
  }
  
  func restoreSavedState() {
    for doText in self.gettingStartedData.dos {
      if let lastTVC = self.doTextViewControllers.last, lastTVC.textView.text.count == 0 || self.sampleStarters.contains(lastTVC.textView.text) {
        populateTVCWithText(text: doText, tvc: lastTVC)
        self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .doType)
      } else {
        self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .doType)
        let lastTVC = self.doTextViewControllers.last!
        populateTVCWithText(text: doText, tvc: lastTVC)
      }
    }
    for dontText in self.gettingStartedData.donts {
      if let lastTVC = self.dontTextViewControllers.last, lastTVC.textView.text.count == 0 || self.sampleStarters.contains(lastTVC.textView.text) {
        populateTVCWithText(text: dontText, tvc: lastTVC)
        self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .dontType)
      } else {
        self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .dontType)
        let lastTVC = self.dontTextViewControllers.last!
        populateTVCWithText(text: dontText, tvc: lastTVC)
      }
    }
  }
  
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GetStartedDoDontViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
  
  func addTitleLabelToStackView(stackView: UIStackView, type: DoDontType) {
    let titleView = UIView(frame: CGRect(x: 0, y: 0, width: self.stackView.frame.width, height: 34))
    titleView.translatesAutoresizingMaskIntoConstraints = false
    
    let thumbImageView = UIImageView(frame: CGRect(x: 20, y: 4, width: 26, height: 26))
    if type == .doType {
      thumbImageView.image = UIImage(named: "onboarding-icon-thumb-do")
    } else {
      thumbImageView.image = UIImage(named: "onboarding-icon-thumb-dont")
    }
    thumbImageView.contentMode = .scaleAspectFit
    titleView.addSubview(thumbImageView)
    
    let textLabel = UILabel(frame: CGRect(x: 50, y: 0, width: titleView.frame.width - 60, height: titleView.frame.height))
    textLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    if type == .doType {
      textLabel.text = "Do..."
    } else {
      textLabel.text = "Don't..."
    }
    
    titleView.addSubview(textLabel)
    
    stackView.addArrangedSubview(titleView)
    stackView.addConstraints([
      NSLayoutConstraint(item: titleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: doDontTitleHeight),
      NSLayoutConstraint(item: titleView, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0)
      ])
    
  }
  
  func addExpandingTextViewControllerToStackView(stackView: UIStackView, type: DoDontType) {
    
    if let expandingTextViewVC = ExpandingTextViewController.instantiate() {
      
      expandingTextViewVC.delegate = self
      self.addChild(expandingTextViewVC)
      if type == .doType {
        expandingTextViewVC.tag = doTextViewControllers.count
        self.stackView.insertArrangedSubview(expandingTextViewVC.view, at: 2 + self.doTextViewControllers.count)
        doTextViewControllers.append(expandingTextViewVC)
      } else {
        expandingTextViewVC.tag = dontTextViewControllers.count
        dontTextViewControllers.append(expandingTextViewVC)
        self.stackView.addArrangedSubview(expandingTextViewVC.view)
      }
      let initialHeight: CGFloat = 42
      expandingTextViewVC.minTextViewSize = initialHeight
      let expandingTextViewHeightConstraint =
        NSLayoutConstraint(item: expandingTextViewVC.view!, attribute: .height, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: initialHeight)
      
      self.stackView.addConstraints([
        expandingTextViewHeightConstraint,
        NSLayoutConstraint(item: expandingTextViewVC.view!, attribute: .width, relatedBy: .equal,
                           toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0)
        ])
      
      expandingTextViewVC.animationDuration = 0.1
      
      expandingTextViewVC.textView.font = UIFont(name: StylingConfig.displayFontRegular, size: 18)
      expandingTextViewVC.textView.isScrollEnabled = false
      expandingTextViewVC.textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)
      expandingTextViewVC.textView.tintColor = UIColor.darkGray
      
      expandingTextViewVC.viewHeightConstraint = expandingTextViewHeightConstraint
      expandingTextViewVC.didMove(toParent: self)
      
      let segmentView = UIView()
      segmentView.translatesAutoresizingMaskIntoConstraints = false
      segmentView.backgroundColor = UIColor(white: 0.4, alpha: 0.2)
      expandingTextViewVC.view.addSubview(segmentView)
      expandingTextViewVC.view.addConstraints([
        NSLayoutConstraint(item: segmentView, attribute: .height, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0),
        NSLayoutConstraint(item: segmentView, attribute: .width, relatedBy: .equal,
                           toItem: expandingTextViewVC.view, attribute: .width, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: segmentView, attribute: .centerX, relatedBy: .equal,
                           toItem: expandingTextViewVC.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: segmentView, attribute: .bottom, relatedBy: .equal,
                           toItem: expandingTextViewVC.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        ])
      
      expandingTextViewVC.setPlaceholderText(text: self.sampleStarters[(self.doTextViewControllers.count + self.dontTextViewControllers.count) % self.sampleStarters.count])
      expandingTextViewVC.permanentTextLabel.font = UIFont(name: StylingConfig.displayFontMedium, size: 18)
    } else {
      print("Failed to create ExpandingTextVC")
    }
  }
  
  func addDoDontGroup() {
    self.addTitleLabelToStackView(stackView: self.stackView, type: .doType)
    self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .doType)
    self.addTitleLabelToStackView(stackView: self.stackView, type: .dontType)
    self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .dontType)
  }
  
}

// MARK: - Expanding Text VC Delegate
extension GetStartedDoDontViewController: ExpandingTextViewControllerDelegate {
  func primaryAccessoryButtonPressed(expandingTextViewController: ExpandingTextViewController, sender: UIButton) {
    
    if sender.tag == 0 {
      // Add clicked
      if self.doTextViewControllers.contains(expandingTextViewController) {
        self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .doType)
      } else if self.dontTextViewControllers.contains(expandingTextViewController) {
        self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .dontType)
      }
      expandingTextViewController.removeAllAccessoryButtons()
      expandingTextViewController.addAccessoryButton(image: UIImage(named: "onboarding-icon-close")!, buttonType: .close)
      expandingTextViewController.textViewDidChange(expandingTextViewController.textView)
      self.returnKeyPressed(expandingTextViewController: expandingTextViewController)
    } else if sender.tag == 1 {
      // Clear case
      if self.doTextViewControllers.contains(expandingTextViewController) {
        if self.doTextViewControllers.count == 1 {
          expandingTextViewController.textView.text = ""
        } else {
          if self.doTextViewControllers.last == expandingTextViewController {
            self.resetButtonsAddClose(expandingTextVC: self.doTextViewControllers[self.doTextViewControllers.count - 2])
          }
          
          self.stackView.removeArrangedSubview(expandingTextViewController.view)
          expandingTextViewController.view.removeFromSuperview()
          if let index = self.doTextViewControllers.firstIndex(of: expandingTextViewController) {
            self.doTextViewControllers.remove(at: index)
          }
        }
      } else if self.dontTextViewControllers.contains(expandingTextViewController) {
        if self.dontTextViewControllers.count == 1 {
          expandingTextViewController.textView.text = ""
        } else {
          if self.dontTextViewControllers.last == expandingTextViewController {
            self.resetButtonsAddClose(expandingTextVC: self.dontTextViewControllers[self.dontTextViewControllers.count - 2])
          }
          
          self.stackView.removeArrangedSubview(expandingTextViewController.view)
          expandingTextViewController.view.removeFromSuperview()
          if let index = self.dontTextViewControllers.firstIndex(of: expandingTextViewController) {
            self.dontTextViewControllers.remove(at: index)
          }
        }
      }
      
    }
  }
  
  func resetButtonsAddClose(expandingTextVC: ExpandingTextViewController) {
    expandingTextVC.removeAllAccessoryButtons()
    expandingTextVC.addAccessoryButton(image: UIImage(named: "onboarding-icon-plus")!, buttonType: .add)
    expandingTextVC.addAccessoryButton(image: UIImage(named: "onboarding-icon-close")!, buttonType: .close)
  }
  
  func seccondaryAccessoryButtonPressed(expandingTextViewController: ExpandingTextViewController, sender: UIButton) {
    if sender.tag == 1 {
      if self.doTextViewControllers.contains(expandingTextViewController) {
        if self.doTextViewControllers.count > 1 {
          if self.doTextViewControllers.last == expandingTextViewController {
            self.resetButtonsAddClose(expandingTextVC: self.doTextViewControllers[self.doTextViewControllers.count - 2])
          }
          
          self.stackView.removeArrangedSubview(expandingTextViewController.view)
          expandingTextViewController.view.removeFromSuperview()
          if let index = self.doTextViewControllers.firstIndex(of: expandingTextViewController) {
            self.doTextViewControllers.remove(at: index)
          }
        } else {
          expandingTextViewController.textView.text = ""
        }
      } else if self.dontTextViewControllers.contains(expandingTextViewController) {
        if self.dontTextViewControllers.count > 1 {
          if self.dontTextViewControllers.last == expandingTextViewController {
            self.resetButtonsAddClose(expandingTextVC: self.dontTextViewControllers[self.dontTextViewControllers.count - 2])
          }
          
          self.stackView.removeArrangedSubview(expandingTextViewController.view)
          expandingTextViewController.view.removeFromSuperview()
          if let index = self.dontTextViewControllers.firstIndex(of: expandingTextViewController) {
            self.dontTextViewControllers.remove(at: index)
          }
        } else {
          expandingTextViewController.textView.text = ""
        }
      }
    }
  }
  
  func textViewDidChange(expandingTextViewController: ExpandingTextViewController) {
    if expandingTextViewController.textView.text.count > 0  &&
      (expandingTextViewController == self.doTextViewControllers.last || expandingTextViewController == self.dontTextViewControllers.last) &&
      expandingTextViewController.primaryAccessoryButton == nil {
      expandingTextViewController.addAccessoryButton(image: UIImage(named: "onboarding-icon-plus")!, buttonType: .add)
      expandingTextViewController.addAccessoryButton(image: UIImage(named: "onboarding-icon-close")!, buttonType: .close)
    }
  }
  
  func returnKeyPressed(expandingTextViewController: ExpandingTextViewController) {
    var nextTextView: UITextView?
    
    if self.doTextViewControllers.contains(expandingTextViewController), let index = self.doTextViewControllers.firstIndex(of: expandingTextViewController) {
      if index < self.doTextViewControllers.count - 1 {
        nextTextView = self.doTextViewControllers[index + 1].textView
      } else {
        if self.doTextViewControllers.contains(expandingTextViewController) {
          self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .doType)
        }
        expandingTextViewController.removeAllAccessoryButtons()
        expandingTextViewController.addAccessoryButton(image: UIImage(named: "onboarding-icon-close")!, buttonType: .close)
        expandingTextViewController.textViewDidChange(expandingTextViewController.textView)
        self.returnKeyPressed(expandingTextViewController: expandingTextViewController)
        return
      }
    } else if self.dontTextViewControllers.contains(expandingTextViewController), let index = self.dontTextViewControllers.firstIndex(of: expandingTextViewController) {
      if index < self.dontTextViewControllers.count - 1 {
        nextTextView = self.dontTextViewControllers[index + 1].textView
      } else {
        if self.dontTextViewControllers.contains(expandingTextViewController) {
          self.addExpandingTextViewControllerToStackView(stackView: self.stackView, type: .dontType)
        }
        expandingTextViewController.removeAllAccessoryButtons()
        expandingTextViewController.addAccessoryButton(image: UIImage(named: "onboarding-icon-close")!, buttonType: .close)
        expandingTextViewController.textViewDidChange(expandingTextViewController.textView)
        self.returnKeyPressed(expandingTextViewController: expandingTextViewController)
        return
      }
    }
    if let nextTextView = nextTextView {
      nextTextView.becomeFirstResponder()
      self.scrollView.scrollRectToVisible(nextTextView.superview!.frame, animated: true)
    } else {
      expandingTextViewController.textView.resignFirstResponder()
    }
  }
  
}

// MARK: - Keybaord Size Notifications
extension GetStartedDoDontViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(GetStartedDoDontViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(GetStartedDoDontViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetFrame = targetFrameNSValue.cgRectValue
      self.nextButtonBottomConstraint.constant = targetFrame.size.height - self.view.safeAreaInsets.bottom + keyboardBottomPadding
      if self.view.frame.height < 600 && targetFrame.height > 0 {
        self.nextButtonBottomConstraint.constant = targetFrame.height - self.view.safeAreaInsets.bottom - self.nextButton.frame.height
      }
      if self.nextButtonBottomConstraint.constant > self.keyboardBottomPadding && self.view.frame.height < 600 {
        self.subtitleLabel.text = ""
      }
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  @objc func keyboardWillHide(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      if self.nextButtonBottomConstraint.constant > self.keyboardBottomPadding && self.view.frame.height < 600 {
        self.subtitleLabel.text = "Should we take them to brunch? Talk about sports? What are their pet peeves?"
      }
      self.nextButtonBottomConstraint.constant = self.keyboardBottomPadding
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
}

extension GetStartedDoDontViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
