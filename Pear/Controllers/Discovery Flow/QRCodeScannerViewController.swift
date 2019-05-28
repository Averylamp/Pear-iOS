//
//  QRCodeScannerViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class QRCodeScannerViewController: UIViewController {

  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> QRCodeScannerViewController? {
    guard let qrCodeScannerVC = R.storyboard.qrCodeScannerViewController.instantiateInitialViewController() else { return nil }
    return qrCodeScannerVC
  }
  
}

// MARK: - Life Cycle
extension QRCodeScannerViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  func setup() {
    
  }
  
  func stylize() {
    
  }
  
}
