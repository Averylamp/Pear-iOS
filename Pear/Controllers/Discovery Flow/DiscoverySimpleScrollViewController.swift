//
//  DiscoverySimpleScrollViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/14/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class DiscoverySimpleScrollViewController: UIViewController {

    var profiles: [ProfileData] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileReviewLabel: UILabel!
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(profiles: [ProfileData]) -> DiscoverySimpleScrollViewController? {
        let storyboard = UIStoryboard(name: String(describing: DiscoverySimpleScrollViewController.self), bundle: nil)
        guard let discoveryScrollVC = storyboard.instantiateInitialViewController() as? DiscoverySimpleScrollViewController else { return nil }
        discoveryScrollVC.profiles = profiles
        return discoveryScrollVC
    }

}

// MARK: - Life Cycle
extension DiscoverySimpleScrollViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none

    }
}

// MARK: - UITableViewDelegate
extension DiscoverySimpleScrollViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileData = self.profiles[indexPath.row]
        guard let fullProfileViewController = FullProfileViewController.instantiate(profileData: profileData) else {
            print("Faield to create Full Profile View")
            return
        }
        self.present(fullProfileViewController, animated: true, completion: {
            fullProfileViewController.addSimpleCloseButton {
                fullProfileViewController.dismiss(animated: true, completion: nil)
            }
        })
    }

}

// MARK: - UITableViewDataSource
extension DiscoverySimpleScrollViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.profiles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoveryProfileSummaryTVC", for: indexPath) as? DiscoveryProfileSummaryTableViewCell
            else { return UITableViewCell() }
        let profileData = self.profiles[indexPath.row]
//        cell.profileImageView.image = profileData.images.first
        cell.profileNameLabel.text = profileData.firstName
        if let endorseeFirstName = profileData.endorsedFirstName {
            var endorsedName = endorseeFirstName
            if let endorsedLastName = profileData.endorsedLastName {
                endorsedName +=  " " + String(endorsedLastName.prefix(1)) + "."
            }
            cell.setEndorseeText(text: "Made by \(endorsedName)")
        } else {
            cell.hideEndorseeCircleView()
        }
        cell.ageLabel.text = "\(profileData.age)"
        cell.setDoText(doText: profileData.doList.first!)
        cell.setDontText(dontText: profileData.dontList.first!)

        return cell
    }

}
