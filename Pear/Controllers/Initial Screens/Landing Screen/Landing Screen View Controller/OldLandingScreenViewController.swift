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
import NVActivityIndicatorView
import SafariServices
import CoreLocation

class OldLandingScreenViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var facebookButton: UIButton!
  @IBOutlet weak var emailButton: UIButton!
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var termsButton: UIButton!
  
  var gettingStarted: Bool = false
  var prevPageNum: Int = 0
  var isLoggingIntoFacebook: Bool = false
  
  var pages: [LandingScreenPageViewController] = []
  let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                                      type: NVActivityIndicatorType.ballScaleRippleMultiple,
                                                      color: StylingConfig.textFontColor,
                                                      padding: 0)
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> OldLandingScreenViewController? {
    let storyboard = UIStoryboard(name: String(describing: OldLandingScreenViewController.self), bundle: nil)
    guard let landingScreenVC = storyboard.instantiateInitialViewController() as? OldLandingScreenViewController else { return nil }
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
  
  @IBAction func termsButtonClicked(_ sender: Any) {
    let actionSheet = UIAlertController(title: "Terms of Service",
                                        message: "What would you like to see?",
                                        preferredStyle: .actionSheet)
    let eulaAction = UIAlertAction(title: "End User License Agreement", style: .default) { (_) in
      self.present(SFSafariViewController(url: NetworkingConfig.eulaURL), animated: true, completion: nil)
    }
    let privacyPolicyAction = UIAlertAction(title: "Privacy Policy", style: .default) { (_) in
      self.present(SFSafariViewController(url: NetworkingConfig.eulaURL), animated: true, completion: nil)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    actionSheet.addAction(eulaAction)
    actionSheet.addAction(privacyPolicyAction)
    actionSheet.addAction(cancelAction)
    self.present(actionSheet, animated: true, completion: nil)
  }
}

// MARK: - Life Cycle
extension OldLandingScreenViewController {
  
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
    
    guard let textFont = R.font.nunitoLight(size: 11),
      let boldFont = R.font.nunitoSemiBold(size: 11) else {
        print("Failed to load in fonts")
        return
    }
    let subtleAttributes = [NSAttributedString.Key.font: textFont,
                            NSAttributedString.Key.foregroundColor: UIColor(white: 0.7, alpha: 1.0)]
    let boldAttributes = [NSAttributedString.Key.font: boldFont,
                          NSAttributedString.Key.foregroundColor: UIColor(white: 0.6, alpha: 1.0)]
    let termsString = NSMutableAttributedString(string: "By continuing you agree to our ",
                                                attributes: subtleAttributes)
    let eulaString = NSMutableAttributedString(string: "EULA",
                                               attributes: boldAttributes)
    let andString = NSMutableAttributedString(string: " and ",
                                              attributes: subtleAttributes)
    let privacyPolicyString = NSMutableAttributedString(string: "privacy policy",
                                                        attributes: boldAttributes)
    termsString.append(eulaString)
    termsString.append(andString)
    termsString.append(privacyPolicyString)
    self.termsButton.setAttributedTitle(termsString, for: .normal)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * CGFloat(self.pages.count), height: self.scrollView.frame.height)
    super.viewDidAppear(animated)
  }
}

// MARK: - Styling
extension OldLandingScreenViewController {
  
  func setupScrollView() {
    let numPages: Int  = self.pages.count
    scrollView.contentSize = CGSize(width: self.scrollView.frame.width * CGFloat(numPages), height: scrollView.frame.size.height)
    scrollView.showsHorizontalScrollIndicator = false
    
    scrollView.isPagingEnabled = true
    pageControl.numberOfPages = numPages
    pageControl.addTarget(self, action: #selector(OldLandingScreenViewController.pageControlChanged(sender:)), for: .valueChanged)
    
    for pageNumber in 0..<self.pages.count {
      self.addChild(self.pages[pageNumber])
      self.pages[pageNumber].view.translatesAutoresizingMaskIntoConstraints = false
      scrollView.addSubview(self.pages[pageNumber].view)
      scrollView.addConstraints([
        NSLayoutConstraint(item: self.pages[pageNumber].view!, attribute: .height, relatedBy: .equal,
                           toItem: scrollView, attribute: .height, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: self.pages[pageNumber].view!, attribute: .width, relatedBy: .equal,
                           toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: self.pages[pageNumber].view!, attribute: .centerY, relatedBy: .equal,
                           toItem: scrollView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: self.pages[pageNumber].view!, attribute: .centerX, relatedBy: .equal,
                           toItem: scrollView, attribute: .centerX, multiplier: 1 + CGFloat(pageNumber * 2), constant: 0.0)
        ])
      self.pages[pageNumber].didMove(toParent: self)
    }
    scrollView.delegate = self
    self.view.layoutIfNeeded()
  }
}

// MARK: - @IBActions
private extension OldLandingScreenViewController {
  func attachButtons() {
    self.facebookButton.addTarget(self, action: #selector(OldLandingScreenViewController.facebookButtonClicked(sender:)), for: .touchUpInside)
    self.emailButton.addTarget(self, action: #selector(OldLandingScreenViewController.emailButtonClicked(sender:)), for: .touchUpInside)
  }
  
  func stylizeFacebookButton(isEnabled: Bool) {
    self.isLoggingIntoFacebook = !isEnabled
    if self.isLoggingIntoFacebook {
      if self.activityIndicatorView.superview == nil {
        self.view.addSubview(self.activityIndicatorView)
        print("Adding activity indicator")
        self.activityIndicatorView.center.y = self.facebookButton.frame.origin.y - 50
        self.activityIndicatorView.center.x = self.facebookButton.center.x
        self.activityIndicatorView.tintColor = R.color.facebookColorSelected()
        self.activityIndicatorView.startAnimating()
      }
      self.facebookButton.backgroundColor = R.color.facebookColorSelected()
      self.facebookButton.isEnabled = false
    } else {
      self.facebookButton.isEnabled = true
      self.facebookButton.stylizeFacebookColor()
      if self.activityIndicatorView.superview != nil {
        self.activityIndicatorView.removeFromSuperview()
      }
    }
  }
  
  func loginWithFacebook() {
    if self.isLoggingIntoFacebook {
      return
    }
    self.stylizeFacebookButton(isEnabled: false)
    let trace = Performance.startTrace(name: "Login With Facebook")
    // 1. Auth via Facebook.
    
    let loginManager = LoginManager()
    
    //   [.publicProfile, .email, .userBirthday, .userGender]
    loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { result in
      switch result {
      case .success:
        trace?.incrementMetric("Facebook Login Successful", by: 1)
        trace?.stop()
        self.handleSuccessfulFacebookLogin(successResult: result)
      case .cancelled:
        trace?.incrementMetric("Facebook Login Cancelled", by: 1)
        trace?.stop()
        self.prevPageNum = 3 // prevents analytics case where 2nd fb auto login not logged
        self.stylizeFacebookButton(isEnabled: true)
      case .failed:
        trace?.incrementMetric("Facebook Login Failed", by: 1)
        trace?.stop()
        self.stylizeFacebookButton(isEnabled: true)
      }
    }
  }
  
  // swiftlint:disable function_body_length
  func handleSuccessfulFacebookLogin(successResult: LoginResult) {
    switch successResult {
    case .success(let grantedPermissions, let deniedPermissions, let accessToken):
      print(grantedPermissions)
      print(deniedPermissions)
      let firebaseFacebookLogin = Performance.startTrace(name: "Firebase Facebook Login")
      
      let gettingStartedUser = OldUserCreationData()
      // 2. Auth via Firebase.
      let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
      gettingStartedUser.primaryAuth = credential
      gettingStartedUser.facebookAccessToken = accessToken.authenticationToken
      if let fbUserID = accessToken.userId {
        gettingStartedUser.facebookId = fbUserID
      }
      Auth.auth().signInAndRetrieveData(with: credential) { _, error in
        if let error = error {
          self.alert(title: "Auth Error", message: error.localizedDescription)
          firebaseFacebookLogin?.incrementMetric("Firebase Facebook Login Unsuccessful", by: 1)
          firebaseFacebookLogin?.stop()
          self.stylizeFacebookButton(isEnabled: true)
          print("Failed to log in user")
          return
        }
        guard let user = Auth.auth().currentUser else {
          firebaseFacebookLogin?.incrementMetric("Firebase Facebook Login Unsuccessful", by: 1)
          firebaseFacebookLogin?.stop()
          print("Failed to log in user")
          self.stylizeFacebookButton(isEnabled: true)
          return
        }
        firebaseFacebookLogin?.incrementMetric("Firebase/Facebook Login Successful", by: 1)
        firebaseFacebookLogin?.stop()
        
        let facebookLoginExistingUserTrace = Performance.startTrace(name: "Facebook Login Check User")
        DataStore.shared.refreshPearUser(completion: { (pearUser) in
          if pearUser != nil {
            facebookLoginExistingUserTrace?.incrementMetric("Facebook Found Existing User", by: 1)
            facebookLoginExistingUserTrace?.stop()
            DataStore.shared.reloadAllUserData()
            // this is basically a copy of almost identical code in LoadingScreenViewController.swift
            DataStore.shared.getNotificationAuthorizationStatus { status in
              if status == .notDetermined {
                // user exists but notification auth status undetermined (likely reinstalled the app?), so prompt again
                if let allowNotificationsVC = AllowNotificationsViewController.instantiate() {
                  DispatchQueue.main.async {
                    self.navigationController?.pushViewController(allowNotificationsVC, animated: true)
                  }
                } else {
                  print("Failed to create Allow Notifications VC")
                  DispatchQueue.main.async {
                    guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
                      print("Failed to create Landing Screen VC")
                      self.stylizeFacebookButton(isEnabled: true)
                      return
                    }
                    self.stylizeFacebookButton(isEnabled: true)
                    self.navigationController?.setViewControllers([mainVC], animated: true)
                  }
                }
              } else {
                let locationAuthStatus = CLLocationManager.authorizationStatus()
                if locationAuthStatus == .authorizedWhenInUse || locationAuthStatus == .authorizedAlways {
                  DispatchQueue.main.async {
                    guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
                      print("Failed to create Landing Screen VC")
                      self.stylizeFacebookButton(isEnabled: true)
                      return
                    }
                    self.stylizeFacebookButton(isEnabled: true)
                    self.navigationController?.setViewControllers([mainVC], animated: true)
                  }
                } else {
                  if let allowLocationVC = AllowLocationViewController.instantiate() {
                    DispatchQueue.main.async {
                      self.navigationController?.pushViewController(allowLocationVC, animated: true)
                    }
                  } else {
                    print("Failed to create Allow Location VC")
                  }
                }
              }
            }
            
          } else {
            facebookLoginExistingUserTrace?.incrementMetric("Facebook Existing User Not Found", by: 1)
            facebookLoginExistingUserTrace?.stop()
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
            
            if !phoneLogin {
              print("Attached phone number not found")
              gettingStartedUser.phoneNumber = nil
            }
            
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
            self.userGraphRequest(gettingStartedUser: gettingStartedUser,
                                  permissions: permissions,
                                  completion: { (fbGraphFilledGSUser  ) in
                if let location = DataStore.shared.lastLocation {
                  fbGraphFilledGSUser.lastLocation = location
                }
                DispatchQueue.main.async {
                  if let nextVC = fbGraphFilledGSUser.getNextInputViewController() {
                    self.stylizeFacebookButton(isEnabled: true)
                    self.navigationController?.pushViewController(nextVC, animated: true)
                  }
                }
            })
          }
        })
        
      }
    default:
      self.stylizeFacebookButton(isEnabled: true)
    }
  }
  
  func userGraphRequest(gettingStartedUser: OldUserCreationData, permissions: [String], completion: @escaping (OldUserCreationData) -> Void) {
    let trace = Performance.startTrace(name: "Facebook Graph Request")
    // Fetch All other User Profile Data available
    let userInfoRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": permissions.joined(separator: ",")])
    userInfoRequest?.start(completionHandler: { (_, result, error) in
      if let error = error {
        print(error)
        trace?.incrementMetric("Facebook Graph Request Unsuccessful", by: 1)
        trace?.stop()
        completion(gettingStartedUser)
        return
      }
      
      if let result = result as? [String: Any] {
        print(result)
        print(type(of: result))
        
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
        
        if let email = result["email"] as? String {
          trace?.incrementMetric("Facebook Graph Request Found Email", by: 1)
          gettingStartedUser.email = email
        }
        if let gender = result["gender"] as? String {
          trace?.incrementMetric("Facebook Graph Request Found Gender", by: 1)
          gettingStartedUser.gender = GenderEnum(rawValue: gender)
        }
        if let birthdayString = result["birthday"] as? String {
          trace?.incrementMetric("Facebook Graph Request Found Birthday", by: 1)
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
          trace?.incrementMetric("Facebook Graph Request Found Thumbnail", by: 1)
          gettingStartedUser.thumbnailURL = thumbnailUrl
        }
        trace?.incrementMetric("Facebook Graph Request Successful", by: 1)
        trace?.stop()
        completion(gettingStartedUser)
      }
    })
  }
  
  /// Handles Facebook Login
  ///
  /// - Parameter sender: Facebook Login Button
  @objc func facebookButtonClicked(sender: UIButton) {
    Analytics.logEvent("LAND_tapFBLogin", parameters: nil)
    self.delay(delay: 1.0) {
      self.gettingStarted = false
    }
    self.gettingStarted = true
    self.loginWithFacebook()
  }
  
  @objc func emailButtonClicked(sender: UIButton) {
    Analytics.logEvent("LAND_tapEmailLogin", parameters: nil)
    guard !self.gettingStarted else { return }
    self.gettingStarted = true
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    guard let emailProviderVC = GetStartedEmailProviderViewController.instantiate(gettingStartedUserData: OldUserCreationData()) else {
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
extension OldLandingScreenViewController: UIScrollViewDelegate {
  /// Scroll View Did Scroll
  ///
  /// Used for realtime resizing of landing pages
  ///
  /// - Parameter scrollView: scrollView
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
    pageControl.currentPage = Int(pageIndex)
    let percentOffset: CGFloat = scrollView.contentOffset.x / scrollView.contentSize.width
    
    // Analytics for viewing pages
    if percentOffset == 0 {
      trackPageView(pageNumber: 0)
    } else if percentOffset == 0.25 {
      trackPageView(pageNumber: 1)
    } else if percentOffset == 0.50 {
      trackPageView(pageNumber: 2)
    } else if percentOffset == 0.75 {
      if prevPageNum != 4 {
        trackPageView(pageNumber: 3)
      }
    } else if percentOffset > 0.8 {
      trackPageView(pageNumber: 4)
    }
    
    // Scale page image views
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
        self.facebookButtonClicked(sender: self.facebookButton)
      }
    }
  }
  
  func trackPageView(pageNumber: Int) {
    if prevPageNum != pageNumber {
      var eventName: String
      if pageNumber == 4 {
        eventName = "LAND_autoFBLogin"
      } else {
        eventName = "LAND_p" + String(pageNumber) + "View"
      }
      Analytics.logEvent(eventName, parameters: nil)
      print(eventName)
      prevPageNum = pageNumber
    }
  }
  
}
