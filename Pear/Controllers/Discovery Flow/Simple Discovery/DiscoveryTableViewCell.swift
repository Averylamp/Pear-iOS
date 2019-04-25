//
//  DiscoveryTableViewCell.swift
//  Pear
//
//  Created by Avery Lamp on 3/31/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SDWebImage
import CoreLocation

protocol DiscoveryTableViewCellDelegate: class {
  //  func fullProfileViewTriggered(profileData: FullProfileDisplayData)
  func receivedVerticalPanTranslation(yTranslation: CGFloat)
  func endedVerticalPanTranslation(yVelocity: CGFloat)
}

struct FakeData {
  var userID: String?
  var firstName: String?
  var age: Int?
  var gender: GenderEnum?
  var bios: [BioItem] = []
  var boasts: [BoastItem] = []
  var roasts: [RoastItem] = []
  var questionResponses: [QuestionResponseItem] = []
  var vibes: [VibeItem] = []
  var imageContainers: [ImageContainer] = []
  var profileOrigin: FullProfileOrigin?
  var originObject: Any?
  var locationName: String?
  var locationCoordinates: CLLocationCoordinate2D?
  var school: String?
  var schoolYear: String?
  var matchingDemographics: MatchingDemographics?
  var matchingPreferences: MatchingPreferences?
  var discoveryTimestamp: Date?
  var profileNumber: Int?
}

class DiscoveryTableViewCell: UITableViewCell {
  
  weak var delegate: DiscoveryTableViewCellDelegate?
  
  var profileData: FakeData!
  var imageViews: [UIImageView] = []
  
  //  var bioView: BioView!
  //  var doView: DoDontView!
  //  var dontView: DoDontView!
  //
  //  private var profilePictures = [UIImageView]()
  //
  //  @IBOutlet weak var profilePicturesScrollView: UIScrollView!
  //
  //  @IBOutlet weak var pageControl: UIPageControl!
  //
  //  private func createProfilePictures() -> [UIImageView] {
  //    let img1 = UIImageView(frame: CGRect(x: 0,
  //                                         y: 0,
  //                                         width: self.profilePicturesScrollView.bounds.width,
  //                                         height: self.profilePicturesScrollView.bounds.width))
  //    img1.image = UIImage(named: "waitlist-pineapple")
  //
  //    let img2 = UIImageView(frame: CGRect(x: 0,
  //                                         y: 0,
  //                                         width: self.profilePicturesScrollView.bounds.width,
  //                                         height: self.profilePicturesScrollView.bounds.width))
  //    img2.image = UIImage(named: "waitlist-pineapple")
  //
  //    return [img1, img2]
  //  }
  //
  //  private func setupProfilePicturesScrollView(pictures: [UIImageView]) {
  //    self.profilePictures = pictures
  //
  //    self.profilePicturesScrollView.frame = CGRect(x: 0,
  //                                                  y: 0,
  //                                                  width: self.bounds.width,
  //                                                  height: self.bounds.width)
  //    self.profilePicturesScrollView.contentSize = CGSize(width: self.profilePicturesScrollView.bounds.width * CGFloat(self.profilePictures.count),
  //                                                        height: self.profilePicturesScrollView.bounds.width)
  //
  //    for i in 0 ..< self.profilePictures.count {
  //      let profilePicture = UIImageView(frame: CGRect(x: 0,
  //                                              y: 0,
  //                                              width: self.profilePicturesScrollView.bounds.width,
  //                                              height: self.profilePicturesScrollView.bounds.width))
  //
  //      self.profilePictures[i].frame = CGRect(x: self.profilePicturesScrollView.bounds.width * CGFloat(i),
  //                                             y: 0,
  //                                             width: self.profilePicturesScrollView.bounds.width,
  //                                             height: self.profilePicturesScrollView.bounds.width)
  //      self.profilePictures[i] = profilePicture
  //
  //      self.profilePicturesScrollView.addSubview(self.profilePictures[i])
  //    }
  //
  //  }
  //
  //  override func awakeFromNib() {
  //    self.profilePicturesScrollView.delegate = self
  //    let pictures = self.createProfilePictures()
  //    self.setupProfilePicturesScrollView(pictures: pictures)
  //    self.pageControl.numberOfPages = Int(pictures.count)
  //    self.pageControl.currentPage = 0
  var indicatorViews: [UIView] = []
  
  @IBOutlet weak var imageScrollView: UIScrollView!
  @IBOutlet weak var scrollViewContentView: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var extraInfoStackView: UIStackView!
  @IBOutlet weak var vibeImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  @IBAction func moreButtonClicked(_ sender: UIButton) {
    
  }
  
}

// MARK: - Cell Configuration
extension DiscoveryTableViewCell {
  func configureCell(profileData: FullProfileDisplayData) {
    
    print(profileData)
    
  }
  
}

// MARK: - UIScrollViewDelegate
extension DiscoveryTableViewCell: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
    
  }
  
}

extension DiscoveryTableViewCell {
  
}
