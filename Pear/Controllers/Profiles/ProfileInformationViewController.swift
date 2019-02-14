//
//  ProfileInformationViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/13/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import MapKit

class ProfileInformationViewController: UIViewController {

    var firstName: String!
    var endorsedName: String?
    var age: Int!
    var locationString: String?
    var locationCoordinate: CLLocationCoordinate2D?
    var school: String?
    var workPosition: String?
    var workCompany: String?
    
    @IBOutlet weak var firstNameLabel: UILabel!
    
    @IBOutlet weak var endorseeLabel: UILabel!
    
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(firstName: String, age: Int, endorsedName: String? = nil, locationData: LocationData? = nil, schoolName: String? = nil, workData: WorkData? = nil) -> ProfileInformationViewController {
        let storyboard = UIStoryboard(name: String(describing: ProfileInformationViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! ProfileInformationViewController
        vc.firstName = firstName
        vc.age = age
        vc.endorsedName = endorsedName
        if let locationData = locationData{
            vc.locationString = locationData.locationString
            vc.locationCoordinate = locationData.locationCoordinate
        }
        vc.school = schoolName
        if let workData = workData{
            vc.workPosition = workData.workPosition
            vc.workCompany = workData.workCompany
        }
        return vc
    }
    
}

// MARK: - Life Cycle
extension ProfileInformationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    func setupViews(){
        self.firstNameLabel.text = self.firstName
        if let endorseeName = self.endorsedName{
            self.endorseeLabel.text = "Made by \(endorseeName)"
            self.endorseeLabel.layer.cornerRadius = 15
            self.endorseeLabel.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.00).cgColor
            self.endorseeLabel.layer.borderWidth = 1.0
        }
        
        
    }
}

