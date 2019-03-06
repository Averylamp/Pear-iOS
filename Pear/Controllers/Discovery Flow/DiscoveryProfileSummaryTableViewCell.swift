//
//  DiscoveryProfileSummaryTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 2/14/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class DiscoveryProfileSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var endorseeNameLabel: UILabel!
    @IBOutlet weak var endorseeCircleView: UIView!
    @IBOutlet weak var ageLabel: UILabel!

    @IBOutlet weak var doLabel: UILabel!

    @IBOutlet weak var dontLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.layer.cornerRadius = 20
        self.shadowView.layer.cornerRadius = 20
        self.shadowView.layer.shadowOpacity = 0.2
        self.shadowView.layer.shadowRadius = 3
        self.shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.containerView.clipsToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.masksToBounds = true
        self.endorseeCircleView.layer.cornerRadius = 18
        self.endorseeCircleView.layer.borderColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00).cgColor
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setEndorseeText(text: String) {
        self.endorseeNameLabel.text = text
        self.endorseeCircleView.layer.borderWidth = 1.0
    }

    func hideEndorseeCircleView() {
        self.endorseeCircleView.layer.borderWidth = 0.0
    }

    func setDoText(doText: String) {
        let correctedText = String(doText.prefix(1)).lowercased() + String(doText.dropFirst())
        let fullDoText = NSMutableAttributedString()
        fullDoText.append(NSAttributedString(string: "Do ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)]))
        fullDoText.append(NSAttributedString(string: correctedText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        doLabel.attributedText = fullDoText
    }

    func setDontText(dontText: String) {
        let correctedText = String(dontText.prefix(1)).lowercased() + String(dontText.dropFirst())
        let fullDoText = NSMutableAttributedString()
        fullDoText.append(NSAttributedString(string: "Don't ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)]))
        fullDoText.append(NSAttributedString(string: correctedText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        dontLabel.attributedText = fullDoText
    }

}
