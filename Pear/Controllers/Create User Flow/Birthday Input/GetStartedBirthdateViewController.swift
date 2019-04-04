//
//  GetStartedBirthdateViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
class GetStartedBirthdateViewController: UIViewController {
  
  @IBOutlet weak var datePicker: UIDatePicker!
  var gettingStartedUserData: UserCreationData!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var nextButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedUserData: UserCreationData) -> GetStartedBirthdateViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedBirthdateViewController.self), bundle: nil)
    guard let userFirstNameVC = storyboard.instantiateInitialViewController() as? GetStartedBirthdateViewController else { return nil }
    userFirstNameVC.gettingStartedUserData = gettingStartedUserData
    return userFirstNameVC
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.gettingStartedUserData.birthdate = self.datePicker.date
    self.gettingStartedUserData.age = Calendar.current.dateComponents([.year], from: self.datePicker.date, to: Date()).year!
    if let age =  self.gettingStartedUserData.age, age >= 18 {
      guard let nextVC = self.gettingStartedUserData.getNextInputViewController() else {
        print("Failed to create next vc")
        return
      }
      self.navigationController?.pushViewController(nextVC, animated: true)
    }
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - Life Cycle
extension GetStartedBirthdateViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
    datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -90, to: Date())
    self.stylize()
  }
  
  func stylize() {
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
    if let boldFont = UIFont(name: StylingConfig.displayFontMedium, size: 28),
      let regularFont = UIFont(name: StylingConfig.displayFontRegular, size: 28) {
      let titleText = NSMutableAttributedString(string: "When's ", attributes: [NSAttributedString.Key.font: regularFont,
                                                                         NSAttributedString.Key.foregroundColor: StylingConfig.textFontColor])
      let yourText = NSAttributedString(string: "your", attributes: [NSAttributedString.Key.font: boldFont,
                                                                         NSAttributedString.Key.foregroundColor: StylingConfig.textFontColor,
                                                                         NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
      let birthdayText = NSAttributedString(string: " birthday?", attributes: [NSAttributedString.Key.font: regularFont,
                                                                         NSAttributedString.Key.foregroundColor: StylingConfig.textFontColor])
      titleText.append(yourText)
      titleText.append(birthdayText)
      self.titleLabel.attributedText = titleText
    }
    self.nextButton.stylizeDark()
  }
  
}
