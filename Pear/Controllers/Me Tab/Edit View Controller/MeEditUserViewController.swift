//
//  MeEditUserViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class MeEditUserViewController: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var doneButton: UIButton!
  
  var profile: FullProfileDisplayData!
  
  class func instantiate(profile: FullProfileDisplayData) -> MeEditUserViewController? {
    let storyboard = UIStoryboard(name: String(describing: MeEditUserViewController.self), bundle: nil)
    guard let editMeVC = storyboard.instantiateInitialViewController() as? MeEditUserViewController else { return nil }
    editMeVC.profile = profile
    return editMeVC
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func doneButtonClicked(_ sender: Any) {
    
  }
  
}

// MARK: - Life Cycle
extension MeEditUserViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
}
