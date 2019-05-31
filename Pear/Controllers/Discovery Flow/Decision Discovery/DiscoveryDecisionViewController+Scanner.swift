//
//  DiscoveryDecisionViewController+Scanner.swift
//  Pear
//
//  Created by Avery Lamp on 5/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

extension DiscoveryDecisionViewController: QRCodeScannerDelegate {
  
  func presentScanner() {
    guard let scannerVC = QRCodeScannerViewController.instantiate() else {
      print("Unable to instantiate QR Code scanner")
      return
    }
    scannerVC.scannerDelegate = self
    self.present(scannerVC, animated: true, completion: nil)
  }

  func didScanUser(fullProfileDisplay: FullProfileDisplayData) {
    self.scannedUser(fullProfileDisplay: fullProfileDisplay)
  }
  
}
