//
//  QRCodeScannerViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol QRCodeScannerDelegate: class {
  func didScanUser(fullProfileDisplay: FullProfileDisplayData)
}

class QRCodeScannerViewController: UIViewController {

  weak var scannerDelegate: QRCodeScannerDelegate?
  
  var captureSession: AVCaptureSession = AVCaptureSession()
  var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  var qrCodeFrameView: UIView?
  
  private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                    AVMetadataObject.ObjectType.code39,
                                    AVMetadataObject.ObjectType.code39Mod43,
                                    AVMetadataObject.ObjectType.code93,
                                    AVMetadataObject.ObjectType.code128,
                                    AVMetadataObject.ObjectType.ean8,
                                    AVMetadataObject.ObjectType.ean13,
                                    AVMetadataObject.ObjectType.aztec,
                                    AVMetadataObject.ObjectType.pdf417,
                                    AVMetadataObject.ObjectType.itf14,
                                    AVMetadataObject.ObjectType.dataMatrix,
                                    AVMetadataObject.ObjectType.interleaved2of5,
                                    AVMetadataObject.ObjectType.qr]
  
  var isReadingQRCode: Bool = false
  let qrCodePrefixes: [String] = [
  "https://getpear.com/go/userid?id=",
  "https://getpear.com/go/refer?id="
  ]
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> QRCodeScannerViewController? {
    guard let qrCodeScannerVC = R.storyboard.qrCodeScannerViewController.instantiateInitialViewController() else { return nil }
    return qrCodeScannerVC
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.dismiss(animated: true, completion: nil)
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
    // Get the back-facing camera for capturing videos
    let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera, .builtInTelephotoCamera],
                                                                  mediaType: AVMediaType.video, position: .back)
    
    guard let captureDevice = deviceDiscoverySession.devices.first else {
      print("Failed to get the camera device")
      return
    }
    
    do {
      // Get an instance of the AVCaptureDeviceInput class using the previous device object.
      let input = try AVCaptureDeviceInput(device: captureDevice)
      
      // Set the input device on the capture session.
      captureSession.addInput(input)
      
      // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
      let captureMetadataOutput = AVCaptureMetadataOutput()
      captureSession.addOutput(captureMetadataOutput)
      
      captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      captureMetadataOutput.metadataObjectTypes = supportedCodeTypes

    } catch {
      // If any error occurs, simply print it out and don't continue any more.
      print("FAILURE SETTING UP QR CODE METADATA")
      print(error)
      return
    }
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    videoPreviewLayer?.frame = view.layer.bounds
    view.layer.insertSublayer(videoPreviewLayer!, at: 0)
    
    // Start video capture.
    captureSession.startRunning()
    
    // Initialize QR Code Frame to highlight the QR code
    self.qrCodeFrameView =  UIView()
    guard let qrCodeFrameView = self.qrCodeFrameView else {
      return
    }
    qrCodeFrameView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
    qrCodeFrameView.layer.borderColor = R.color.primaryBrandColor()?.cgColor
    qrCodeFrameView.layer.borderWidth = 4
    qrCodeFrameView.layer.cornerRadius = 8
    view.addSubview(qrCodeFrameView)
  }
  
  func stylize() {
    
  }
  
}

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
  
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if metadataObjects.count == 0 {
      self.qrCodeFrameView?.frame = CGRect.zero
      return
    }
    
    if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
      supportedCodeTypes.contains(metadataObj.type),
      let qrCodeString = metadataObj.stringValue,
      self.qrCodePrefixes.contains(where: { qrCodeString.hasPrefix($0)}) {
      guard !self.isReadingQRCode else {
        return
      }
      self.isReadingQRCode = true
      
      print(qrCodeString)
      if let prefixLength = self.qrCodePrefixes.filter({ qrCodeString.hasPrefix($0)}).first?.length {
        let userID = qrCodeString.substring(fromIndex: prefixLength)
        print("Finding user: \(userID)")
        PearUserAPI.shared.getUserFromQRCode(userID: userID) { (result) in
          DispatchQueue.main.async {
            switch result {
            case .success(let fullProfileDisplay):
              if let scannerDelegate = self.scannerDelegate {
                scannerDelegate.didScanUser(fullProfileDisplay: fullProfileDisplay)
              }
              self.dismiss(animated: true, completion: {
                self.isReadingQRCode = false
              })
            case .failure(let error):
              print("Failed to get qr code user: \(error)")
              switch error {
              case .errorWithMessage(let message):
                self.alert(title: message, message: "Please try again later")
              default:
                self.alert(title: "Unable to find user", message: "Sorry, please try again later")
              }
              self.isReadingQRCode = false
            }
          }
        }
      }
//      let userID = qrCodeString.
      // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
      if let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj) {
        self.qrCodeFrameView?.frame = barCodeObject.bounds
      }
      
    }
  }
}
