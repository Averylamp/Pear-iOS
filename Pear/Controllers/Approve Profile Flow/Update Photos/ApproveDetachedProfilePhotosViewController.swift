//
//  GetStartedPhotoInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ApproveDetachedProfilePhotosViewController: UIViewController {
  
  var detachedProfile: PearDetachedProfile!
  
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
  let pageNumber: CGFloat = 1.0
  
  let betweenImageSpacing: CGFloat = 6
  var originalDetachedProfileImages: [ImageContainer] = []
  var images: [GettingStartedUIImageContainer] = []
  var imageBank: [GettingStartedUIImageContainer] = []
  let imagePickerController = UIImagePickerController()
  var longPressGestureRecognizer: UILongPressGestureRecognizer!
  var justMovedIndexPath: IndexPath?
  var hasClickedNext = false
  var imageReplacementIndexPath: IndexPath?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(detachedProfile: PearDetachedProfile,
                         displayedImages: [GettingStartedUIImageContainer],
                         imageBank: [GettingStartedUIImageContainer]) -> ApproveDetachedProfilePhotosViewController? {
    let storyboard = UIStoryboard(name: String(describing: ApproveDetachedProfilePhotosViewController.self), bundle: nil)
    guard let photoInputVC = storyboard.instantiateInitialViewController() as? ApproveDetachedProfilePhotosViewController else { return nil }
    photoInputVC.detachedProfile = detachedProfile
    photoInputVC.originalDetachedProfileImages = detachedProfile.images
    photoInputVC.images = displayedImages
    photoInputVC.imageBank = imageBank
    return photoInputVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    
    if self.images.compactMap({ $0.imageContainer }).count != self.images.count {
      if self.hasClickedNext {
        return
      }
      self.hasClickedNext = true
      let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                                      type: NVActivityIndicatorType.ballScaleRippleMultiple,
                                                      color: StylingConfig.textFontColor,
                                                      padding: 0)
      self.view.addSubview(activityIndicator)
      activityIndicator.center = CGPoint(x: self.view.center.x,
                                         y: self.nextButton.frame.origin.y - 40)
      activityIndicator.startAnimating()
      return
    }
    
    self.detachedProfile.images = self.images.compactMap({ $0.imageContainer })
    if let userID = DataStore.shared.currentPearUser?.documentID {
      PearImageAPI.shared.updateImages(userID: userID,
                                       displayedImages: self.detachedProfile.images,
                                       additionalImages: self.originalDetachedProfileImages) { (result) in
                                        DispatchQueue.main.async {
                                          switch result {
                                          case .success(let success):
                                            if success {
                                              print("Successfully updated User's Images")
                                              if self.detachedProfile.images.count == 0 {
                                                self.alert(title: "Please Upload 🎑", message: "You must have at least one image")
                                                return
                                              }
                                              guard let profileApprovalVC = ApproveDetachedProfileViewController.instantiate(detachedProfile: self.detachedProfile) else {
                                                print("Failed to create Approve Detached Profile VC")
                                                return
                                              }
                                              self.navigationController?.pushViewController(profileApprovalVC, animated: true)
                                            } else {
                                              print("Failure updating User's Images")
                                              self.alert(title: "Image Upload Failure", message: "Our server is feeling kinda down today.  Please try again later")
                                            }
                                          case .failure(let error):
                                            print(error)
                                            self.alert(title: "Image Upload Failure", message: "Our server is feeling kinda down today.  Please try again later")
                                          }
                                          self.hasClickedNext = false
                                        }
      }
      
    }
  }
}

// MARK: - Life Cycle
extension ApproveDetachedProfilePhotosViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupCollectionView()
    imagePickerController.delegate = self
    self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ApproveDetachedProfilePhotosViewController.handleLongGesture(gesture:)))
    self.collectionView.addGestureRecognizer(self.longPressGestureRecognizer)
    self.stylize()
  }
  
  func stylize() {
    self.nextButton.stylizeDark()
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
    
    self.progressWidthConstraint.constant = (pageNumber - 1.0) / StylingConfig.totalProfileApprovalPagesNumber * self.view.frame.width
    self.view.layoutIfNeeded()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.view.layoutIfNeeded()
    self.progressWidthConstraint.constant = pageNumber / StylingConfig.totalProfileApprovalPagesNumber * self.view.frame.width
    UIView.animate(withDuration: StylingConfig.progressBarAnimationDuration, delay: StylingConfig.progressBarAnimationDelay, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  func setupCollectionView() {
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
  }
  
}

// MARK: - UICollectionViewDelegate
extension ApproveDetachedProfilePhotosViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.item >= self.images.count {
      self.imageReplacementIndexPath = nil
    } else {
      self.imageReplacementIndexPath = indexPath
    }
    let title = indexPath.item >= self.images.count ? "Add Image" : "Replace Image"
    let subtitle = indexPath.item >= self.images.count ? "" : "You can only replace images"
    
    let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
      self.openCamera()
    }))
    
    alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
      self.openGallery()
    }))
    
    alert.addAction(UIAlertAction(title: "Suggested by Friends", style: .default, handler: { _ in
      self.openPhotoBank()
    }))
    
    alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func openCamera() {
    if UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
      imagePickerController.sourceType = UIImagePickerController.SourceType.camera
      imagePickerController.allowsEditing = false
      self.present(imagePickerController, animated: true, completion: nil)
    } else {
      let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func openGallery() {
    imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
    imagePickerController.allowsEditing = false
    self.present(imagePickerController, animated: true, completion: nil)
  }
  
  func openPhotoBank() {
    self.alert(title: "Feature Unavailable", message: "This feature is currently unavailable, but will be released soon")
  }
  
}

// MARK: - UICollectionViewDelegate Reordering
extension ApproveDetachedProfilePhotosViewController {
  
  func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    return indexPath.item < self.images.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                      toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
    if proposedIndexPath.item >= self.images.count {
      return originalIndexPath
    }
    return proposedIndexPath
  }
  
  func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    if destinationIndexPath.item < sourceIndexPath.item {
      let image = self.images.remove(at: sourceIndexPath.item)
      self.images.insert(image, at: destinationIndexPath.item)
    } else {
      let image = self.images[sourceIndexPath.item]
      self.images.insert(image, at: destinationIndexPath.item + 1)
      self.images.remove(at: sourceIndexPath.item)
    }
    self.justMovedIndexPath = destinationIndexPath
    var imageIndexPaths: [IndexPath] = []
    for imageNumber in 0..<self.images.count {
      imageIndexPaths.append(IndexPath(item: imageNumber, section: 0))
    }
    self.collectionView.reloadItems(at: imageIndexPaths)
  }
  
  @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began:
      guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
        break
      }
      self.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
    case .changed:
      let gestureLocation = gesture.location(in: gesture.view!)
      if self.collectionView.bounds.contains(gestureLocation) {
        self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        
      } else {
        self.collectionView.cancelInteractiveMovement()
      }
      
    case .ended:
      self.collectionView.endInteractiveMovement()
    default:
      self.collectionView.cancelInteractiveMovement()
    }
  }
  
}

// MARK: - UICollectionViewDataSource
extension ApproveDetachedProfilePhotosViewController: UICollectionViewDataSource, ImageUploadCollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 6
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if indexPath.item < self.images.count {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageUploadCollectionViewCell", for: indexPath) as? ImageUploadCollectionViewCell else {
        return UICollectionViewCell()
      }
      cell.cancelButton.isHidden = true
      if let image = self.images[indexPath.row].image {
        cell.imageView.image = image
      } else if let urlString = self.images[indexPath.row].imageContainer?.thumbnail.imageURL, let imageURL = URL(string: urlString) {
        cell.imageView.image = nil
        cell.imageView.sd_setImage(with: imageURL, placeholderImage: nil, options: .highPriority, progress: nil, completed: nil)
      }
      if let imageID = self.images[indexPath.row].imageContainer?.imageID,
        self.originalDetachedProfileImages.contains(where: { $0.imageID == imageID }) {
        cell.imageView.layer.borderColor = R.color.brandPrimaryDark()?.cgColor
        cell.imageView.layer.borderWidth = 3
      } else {
        cell.imageView.layer.borderColor = nil
        cell.imageView.layer.borderWidth = 0
      }
      
      cell.imageView.contentMode = .scaleAspectFill
      cell.imageView.layer.cornerRadius = 3
      cell.imageView.clipsToBounds = true
      cell.closeButtonDelegate = self
      cell.cancelButton.tag = indexPath.item
      return cell
    } else {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageUploadAddCollectionViewCell", for: indexPath) as? ImageUploadAddCollectionViewCell else {
        return UICollectionViewCell()
      }
      if indexPath.item == self.images.count {
        cell.imageView.image = UIImage(named: "onboarding-add-image-primary")
      } else {
        cell.imageView.image = UIImage(named: "onboarding-add-image-secondary")
      }
      cell.imageView.contentMode = .scaleAspectFill
      return cell
    }
  }
  
  func closeButtonClicked(tag: Int) {
    self.images.remove(at: tag)
    self.collectionView.reloadData()
  }
  
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ApproveDetachedProfilePhotosViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let sideLength: CGFloat = (collectionView.frame.size.width  - ( 2 * betweenImageSpacing)) / 3.0
    return CGSize(width: sideLength, height: sideLength)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return betweenImageSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return betweenImageSpacing
  }
  
}

// MARK: - UIPickerControllerDelegate
extension ApproveDetachedProfilePhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let userID = DataStore.shared.currentPearUser?.documentID {
      let loadingImageContainer = pickedImage.gettingStartedImage(size: .original)
      if let replacementIndex = self.imageReplacementIndexPath {
        self.images.remove(at: replacementIndex.row)
        self.images.insert(loadingImageContainer, at: replacementIndex.row)
      } else {
        self.images.append(loadingImageContainer)
      }
      self.collectionView.reloadData()
      PearImageAPI.shared.uploadNewImage(with: pickedImage, userID: userID) { result in
        switch result {
        case .success( let imageAllSizesRepresentation):
          print("Uploaded Image Successfully")
          loadingImageContainer.imageContainer = imageAllSizesRepresentation
          if self.hasClickedNext {
            DispatchQueue.main.async {
              self.nextButtonClicked(self.nextButton as Any)              
            }
          }
        case .failure:
          print("Failed Uploading Image")
        }
        
      }
    }
    picker.dismiss(animated: true, completion: nil)
  }
  
}
