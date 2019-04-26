//
//  MultipleBoastRoastStackViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class MultipleBoastRoastStackViewController: UIViewController {

  @IBOutlet var scrollView: UIScrollView!
  @IBOutlet var stackView: UIStackView!
  var mode: RoastBoastType = .boast
  @IBOutlet weak var spacerView: UIView!
  
  var textVCs: [ExpandingBoastRoastInputViewController] = []

  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(type: RoastBoastType) -> MultipleBoastRoastStackViewController? {
    guard let multiBoastRoastVC = R.storyboard.multipleBoastRoastStackViewController()
      .instantiateInitialViewController() as? MultipleBoastRoastStackViewController else { return nil }
    multiBoastRoastVC.mode = type
    return multiBoastRoastVC
  }
  
}

// MARK: - Life Cycle
extension MultipleBoastRoastStackViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    
  }
  
  func setup() {

    self.addBoastRoastVC()
  }
  
  func addBoastRoastVC() {
    guard let expandingTextVC = ExpandingBoastRoastInputViewController.instantiate(type: self.mode == .boast ? .boast : .roast) else {
      print("Failed to create expanding b/roast text vc")
      return
    }
    
    expandingTextVC.delegate = self
    self.textVCs.append(expandingTextVC)
    self.addChild(expandingTextVC)
    if let spacerIndex = self.stackView.arrangedSubviews.firstIndex(of: self.spacerView) {
      self.stackView.insertArrangedSubview(expandingTextVC.view, at: spacerIndex)
    } else {
      self.stackView.addArrangedSubview(expandingTextVC.view)
    }
    expandingTextVC.didMove(toParent: self)
    self.view.layoutIfNeeded()
    expandingTextVC.expandingTextView.becomeFirstResponder()
  }
  
  func getBoastRoastItems() -> [BoastRoastItem] {
    return self.textVCs.filter({ $0.type == .roast}).compactMap({ $0.getBoastRoastItem()})
  }
  
}

// MARK: - Dismiss First Responder on Click
extension MultipleBoastRoastStackViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MultipleBoastRoastStackViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
}

// MARK: - ExpandingBoastRoastInputViewDelegate
extension MultipleBoastRoastStackViewController: ExpandingBoastRoastInputViewDelegate {
  func returnPressed(controller: ExpandingBoastRoastInputViewController) {
    DispatchQueue.main.async {
      self.addBoastRoastVC()
    }
  }
  
  func deleteButtonPressed(controller: ExpandingBoastRoastInputViewController) {
    guard self.textVCs.count > 1 else {
      print("Cant remove last remaining item")
      controller.expandingTextView.text = ""
      return
    }
    guard self.stackView.arrangedSubviews.firstIndex(where: { $0 == controller.view }) != nil,
      let arrayIndex = self.textVCs.firstIndex(of: controller) else {
        print("Unable to find indices to remove")
        return
    }
    
    self.stackView.removeArrangedSubview(controller.view)
    controller.view.removeFromSuperview()
    self.textVCs.remove(at: arrayIndex)
  }
  
}
