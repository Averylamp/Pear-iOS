//
//  UserLocationViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/2/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import CoreLocation

class UserLocationViewController: UpdateUIViewController {

  private var initialLocationName: String?
  var locationName: String?
  private var initialLocationCoordinate: CLLocationCoordinate2D?
  var locationCoordinate: CLLocationCoordinate2D?
  
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var locationFieldContainer: UIView!
  @IBOutlet weak var locationTextField: UITextField!
  @IBOutlet weak var locationSubtitleLabel: UILabel!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(locationName: String?, locationCoordinates: CLLocationCoordinate2D?) -> UserLocationViewController? {
    let storyboard = UIStoryboard(name: String(describing: UserLocationViewController.self), bundle: nil)
    guard let locationPrefVC = storyboard.instantiateInitialViewController() as? UserLocationViewController else { return nil }
    locationPrefVC.initialLocationName = locationName
    locationPrefVC.initialLocationCoordinate = locationCoordinates
    locationPrefVC.locationName = locationName
    locationPrefVC.locationCoordinate = locationCoordinates
    return locationPrefVC
  }
  
  override func didMakeUpdates() -> Bool {
    if (initialLocationCoordinate == nil && locationCoordinate != nil) ||
      initialLocationCoordinate != nil && locationCoordinate == nil {
      return true
    }
    if let initialCoordinate = initialLocationCoordinate,
      let coordinate = locationCoordinate {
      if initialCoordinate.latitude != coordinate.latitude ||
        initialCoordinate.longitude != coordinate.longitude {
        return true
      }
    }
    return initialLocationName != locationName
  }
  
}

// MARK: - Life Cycle
extension UserLocationViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.updateLabels()
    self.locationTextField.delegate = self
  }
  
  func stylize() {
    self.titleLabel.stylizePreferencesTitleLabel()
  
    self.locationFieldContainer.stylizeInputTextFieldContainer()
    self.locationTextField.stylizeInputTextField()
    self.locationSubtitleLabel.stylizeTextFieldTitle()
    
  }
  
  func updateLabels() {
    if let locationName = self.locationName {
      self.locationTextField.text = locationName
    }
  }
}

extension UserLocationViewController: UITextFieldDelegate {
  
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    if let text = textField.text, text.count > 0 {
      self.locationName = text
    } else {
      self.locationName = nil
    }
    self.updateLabels()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if let text = textField.text, text.count + string.count - range.length > 30 {
      return false
    }
    return true
  }
  
}
