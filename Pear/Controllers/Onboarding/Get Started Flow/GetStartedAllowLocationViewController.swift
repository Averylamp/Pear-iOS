//
//  GetStartedAllowLocationViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/28/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import CoreLocation

class GetStartedAllowLocationViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var enableLocationButton: UIButton!

    let locationManager = CLLocationManager()
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> GetStartedAllowLocationViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedAllowLocationViewController.self), bundle: nil)
        guard let allowLocationVC = storyboard.instantiateInitialViewController() as? GetStartedAllowLocationViewController else { return nil }
        return allowLocationVC
    }

    @IBAction func enableLocationClicked(_ sender: Any) {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {

            // present an alert indicating location authorization required
            // and offer to take the user to Settings for the app via
            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString

            locationManager.requestWhenInUseAuthorization()
        } else if status == .denied {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Location Required",
                                              message: "Location is required, please enable Location in the Settigs app.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Go to Settings now", style: .default, handler: { (_: UIAlertAction!) in
                    print("")

                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: { (finished) in
                        print(finished)
                        print("Finished")
                    })
                }))
                // self.presentViewController(alert, animated: true, completion: nil)
                UIApplication.shared.keyWindow!.rootViewController?.present(alert, animated: true, completion: nil)
            }

        }

    }

}

// MARK: - Life Cycle
extension GetStartedAllowLocationViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.stylize()
    }

    func stylize() {
        self.enableLocationButton.stylizeAllowFeature()
        self.titleLabel.stylizeTitleLabel()
        self.subtitleLabel.stylizeSubtitleLabel()
    }

}
