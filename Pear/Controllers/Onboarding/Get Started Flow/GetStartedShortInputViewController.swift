//
//  GetStartedShortInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/8/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedShortInputViewController: UIViewController {
    
    var questionText:String = ""
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    var validateInput: (String) -> String? = { (input) -> String? in return nil }
    var completedInput: (String) ->Void = { (input) -> Void in return}
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(question: String, validateInput: @escaping (String) -> String?, completedInput: @escaping(String) -> Void) -> GetStartedShortInputViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedShortInputViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedShortInputViewController
        vc.questionText = question
        vc.validateInput = validateInput
        vc.completedInput = completedInput
        return vc
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        if let errorMessage =  self.validateInput(self.inputTextField.text!){
            // error validating input
            // no-op
        }else{
            // input validated
            self.completedInput(self.inputTextField.text!)
        }
    }
    
}


// MARK: - Life Cycle
extension GetStartedShortInputViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.questionLabel.text = questionText
        self.nextButton.contentMode = .scaleAspectFit
        self.nextButton.layer.shadowRadius = 3
        self.nextButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.nextButton.layer.shadowOpacity = 0.4
        self.nextButton.layer.shadowColor = UIColor.black.cgColor
    }
}

// MARK: - @IBAction
private extension GetStartedShortInputViewController{
    
    
    
    
}
