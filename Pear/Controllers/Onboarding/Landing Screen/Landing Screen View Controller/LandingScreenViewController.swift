//
//  LandingScreenViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/8/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKCoreKit
import Firebase
import SwiftyJSON

class LandingScreenViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var facebookButton: UIButton!
  @IBOutlet weak var emailButton: UIButton!
  @IBOutlet weak var pageControl: UIPageControl!
  
  var gettingStarted: Bool = false
  
  var pages: [LandingScreenPageViewController] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> LandingScreenViewController? {
    let storyboard = UIStoryboard(name: String(describing: LandingScreenViewController.self), bundle: nil)
    guard let landingScreenVC = storyboard.instantiateInitialViewController() as? LandingScreenViewController else { return nil }
    guard let page1VC = LandingScreenPage1ViewController.instantiate() else {
      print("Failed to create Page 1")
      return nil
    }
    
    guard let page2VC = LandingScreenPage2ViewController.instantiate() else {
      print("Failed to create Page 2")
      return nil
    }
    
    guard let page3VC = LandingScreenPage3ViewController.instantiate() else {
      print("Failed to create Page 3")
      return nil
    }
    
    guard let page4VC = LandingScreenPage4ViewController.instantiate() else {
      print("Failed to create Page 4")
      return nil
    }
    
    landingScreenVC.pages = [page1VC,
                             page2VC,
                             page3VC,
                             page4VC]
    return landingScreenVC
  }
  
}

// MARK: - Life Cycle
extension LandingScreenViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.stylize()
    self.attachButtons()
    self.setupScrollView()
    
  }
  
  func stylize() {
    self.facebookButton.stylizeFacebookColor()
    self.facebookButton.addMotionEffect(MotionEffectGroupGenerator.getMotionEffectGroup(maxDistance: 3.0))
    
    self.emailButton.stylizeLight()
    self.emailButton.addMotionEffect(MotionEffectGroupGenerator.getMotionEffectGroup(maxDistance: 3.0))
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * CGFloat(self.pages.count), height: self.scrollView.frame.height)
    super.viewDidAppear(animated)
  }
}

// MARK: - Styling
extension LandingScreenViewController {
  
  func setupScrollView() {
    let numPages: Int  = self.pages.count
    scrollView.contentSize = CGSize(width: self.scrollView.frame.width * CGFloat(numPages), height: scrollView.frame.size.height)
    scrollView.showsHorizontalScrollIndicator = false
    
    scrollView.isPagingEnabled = true
    pageControl.numberOfPages = numPages
    pageControl.addTarget(self, action: #selector(LandingScreenViewController.pageControlChanged(sender:)), for: .valueChanged)
    
    for pageNumber in 0..<self.pages.count {
      self.addChild(self.pages[pageNumber])
      self.pages[pageNumber].view.translatesAutoresizingMaskIntoConstraints = false
      scrollView.addSubview(self.pages[pageNumber].view)
      scrollView.addConstraints([
        NSLayoutConstraint(item: self.pages[pageNumber].view, attribute: .height, relatedBy: .equal,
                           toItem: scrollView, attribute: .height, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: self.pages[pageNumber].view, attribute: .width, relatedBy: .equal,
                           toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: self.pages[pageNumber].view, attribute: .centerY, relatedBy: .equal,
                           toItem: scrollView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: self.pages[pageNumber].view, attribute: .centerX, relatedBy: .equal,
                           toItem: scrollView, attribute: .centerX, multiplier: 1 + CGFloat(pageNumber * 2), constant: 0.0)
        ])
      self.pages[pageNumber].didMove(toParent: self)
    }
    scrollView.delegate = self
    self.view.layoutIfNeeded()
  }
}

// MARK: - @IBActions
private extension LandingScreenViewController {
  func attachButtons() {
    self.facebookButton.addTarget(self, action: #selector(LandingScreenViewController.facebookButtonClicked(sender:)), for: .touchUpInside)
    self.emailButton.addTarget(self, action: #selector(LandingScreenViewController.emailButtonClicked(sender:)), for: .touchUpInside)
  }
  
  /// Handles Facebook Login
  ///
  /// - Parameter sender: Facebook Login Button
  @objc func facebookButtonClicked(sender: UIButton) {
    let loginManager = LoginManager()
    self.delay(delay: 1.0) {
      self.gettingStarted = false
    }
    // 1. Auth via Facebook.
    loginManager.logIn(readPermissions: [.publicProfile, .email, .userBirthday, .userGender], viewController: self) { result in
      switch result {
        
      case .success(let grantedPermissions, let deniedPermissions, let accessToken):
        print(grantedPermissions)
        print(deniedPermissions)
        
        var permissions: [String] = ["id", "first_name", "last_name", "picture.width(300).height(300)"]
        
        if  grantedPermissions.contains("email") {
          permissions.append("email")
        }
        if  grantedPermissions.contains("user_birthday") {
          permissions.append("birthday")
        }
        if  grantedPermissions.contains("user_gender") {
          permissions.append("gender")
        }
        
        // Fetch All other User Profile Data available
        let userInfoRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": permissions.joined(separator: ",")])
        userInfoRequest?.start(completionHandler: { (_, result, error) in
          if let error = error {
            print(error)
            return
          }
          
          if let result = result as? [String: Any] {
            print(result)
            print(type(of: result))
            let gettingStartedUser = GettingStartedUserData()
            guard   let firstName = result["first_name"],
              let lastName = result["last_name"],
              let fbid = result["id"] else {
                print(error as Any)
                print("Failed to get basic data")
                return
            }
            
            gettingStartedUser.firstName = firstName as? String
            gettingStartedUser.lastName = lastName as? String
            gettingStartedUser.facebookId = "\(fbid)"
            gettingStartedUser.facebookAccessToken = accessToken.authenticationToken
            
            if let email = result["email"] as? String {
              gettingStartedUser.email = email
            }
            
            if let gender = result["gender"] as? String {
              gettingStartedUser.gender = GenderEnum(rawValue: gender)
            }
            
            if let birthdayString = result["birthday"] as? String {
              let dateFormatter = DateFormatter()
              dateFormatter.dateFormat = "MM/dd/yyyy"
              if let birthdate = dateFormatter.date(from: birthdayString) {
                gettingStartedUser.birthdate = birthdate
                
                if let age = Calendar.current.dateComponents([.year], from: birthdate, to: Date()).year {
                  gettingStartedUser.age = age
                }
                
              }
            }
            
            if  let thumbnailUrl = JSON(result)["picture"]["data"]["url"].string {
              gettingStartedUser.thumbnailURL = thumbnailUrl
            }
            
            // 2. Auth via Firebase.
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
            gettingStartedUser.primaryAuth = credential
            Auth.auth().signInAndRetrieveData(with: credential) { _, error in
              if let error = error {
                self.alert(title: "Auth Error", message: error.localizedDescription)
                return
              }
              guard let user = Auth.auth().currentUser else {
                print("Failed to log in user")
                return
              }
              
              gettingStartedUser.firebaseAuthID = user.uid
              
              var facebookLogin = false
              var emailLogin = false
              var phoneLogin = false
              
              user.providerData.forEach({ (userInfo) in
                print(userInfo.providerID)
                if userInfo.providerID == FacebookAuthProviderID {
                  print("Facebook Found")
                  facebookLogin = true
                } else if userInfo.providerID == EmailAuthProviderID {
                  print("Email Found")
                  emailLogin = true
                } else if userInfo.providerID == PhoneAuthProviderID {
                  print("Phone Found")
                  phoneLogin = true
                }
              })
              if (facebookLogin && phoneLogin) || (emailLogin && phoneLogin) {
                print("Probably already created account")
              }
              
              if let nextVC = gettingStartedUser.getNextInputViewController() {
                self.navigationController?.pushViewController(nextVC, animated: true)
              }
            }
          }
        })
      case .cancelled:
        break
      case .failed:
        break
      }
    }
    
  }
  
  @objc func emailButtonClicked(sender: UIButton) {
    guard !self.gettingStarted else { return }
    self.gettingStarted = true
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let emailProviderVC = GetStartedEmailProviderViewController.instantiate(gettingStartedUserData: GettingStartedUserData()) else {
      print("Failed to create Email Provider VC")
      return
    }
    self.navigationController?.pushViewController(emailProviderVC, animated: true)
    self.delay(delay: 1.0) {
      self.gettingStarted = false
    }
  }
  
  @objc func pageControlChanged(sender: UIPageControl) {
    let pageIndex: Int = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
    if sender.currentPage != pageIndex {
      scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.width * CGFloat(sender.currentPage), y: 0), animated: true)
    }
  }
}

// MARK: - UIScrollViewDelegate
extension LandingScreenViewController: UIScrollViewDelegate {
  
  /// Scroll View Did Scroll
  ///
  /// Used for realtime resizing of landing pages
  ///
  /// - Parameter scrollView: scrollView
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
    pageControl.currentPage = Int(pageIndex)
    let percentOffset: CGFloat = scrollView.contentOffset.x / scrollView.contentSize.width
    
    if percentOffset < 0 {
      pages[0].scaleImageView(percent: 1 + ((percentOffset) * 4), before: true)
    } else if percentOffset > 0 && percentOffset <= 0.25 {
      pages[0].scaleImageView(percent: 1 - ((percentOffset) * 4), before: false)
      pages[1].scaleImageView(percent: percentOffset * 4, before: true)
    } else if percentOffset > 0.25 && percentOffset <= 0.50 {
      pages[1].scaleImageView(percent: 1 - (percentOffset - 0.25) * 4, before: false)
      pages[2].scaleImageView(percent: (percentOffset - 0.25) * 4, before: true)
    } else if percentOffset > 0.50 && percentOffset <= 0.75 {
      pages[2].scaleImageView(percent: 1 - (percentOffset - 0.5) * 4, before: false)
      pages[3].scaleImageView(percent: (percentOffset - 0.5) * 4, before: true)
    } else if percentOffset > 0.75 && percentOffset <= 1 {
      pages[3].scaleImageView(percent: 1 - (percentOffset - 0.75) * 4, before: false)
      if percentOffset > 0.8 {
        print("Autotrigger get started")
        //                self.signupButtonClicked(sender: UIButton())
      }
    }
  }
  
}
