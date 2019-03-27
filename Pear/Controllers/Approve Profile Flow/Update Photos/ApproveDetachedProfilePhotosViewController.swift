//
//  GetStartedPhotoInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ApproveDetachedProfilePhotosViewController: UIViewController {
  
  var detachedProfile: PearDetachedProfile!
  
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
  let pageNumber: CGFloat = 7.0
  
  let betweenImageSpacing: CGFloat = 6
  var images: [GettingStartedUIImageContainer] = []
  let imagePickerController = UIImagePickerController()
  var longPressGestureRecognizer: UILongPressGestureRecognizer!
  var justMovedIndexPath: IndexPath?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(detachedProfile: PearDetachedProfile, displayedImages:[GettingStartedUIImageContainer]) -> ApproveDetachedProfilePhotosViewController? {
    let storyboard = UIStoryboard(name: String(describing: ApproveDetachedProfilePhotosViewController.self), bundle: nil)
    guard let photoInputVC = storyboard.instantiateInitialViewController() as? ApproveDetachedProfilePhotosViewController else { return nil }
    photoInputVC.detachedProfile = detachedProfile
    photoInputVC.images = displayedImages
    return photoInputVC
  }
  
  func saveImages() {
//    self.detachedProfile.images = self.images.compactMap({ $0.imageContainer })
    // TODO: Image Update Here
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.saveImages()
    
    if self.detachedProfile.images.count == 0 {
      self.alert(title: "Please Upload 🎑", message: "You must upload at least one image")
      return
    }
    
//    guard let profileReviewVC = FullProfileReviewViewController.instantiate(gettingStartedUserProfileData: self.detachedProfile) else {
//      print("Failed to create scrolling Full VC")
//      return
//    }
//    self.navigationController?.pushViewController(profileReviewVC, animated: true)

  }
  
}

// MARK: - Life Cycle
extension ApproveDetachedProfilePhotosViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.restoreGettingStartedState()
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
    
    self.progressWidthConstraint.constant = (pageNumber - 1.0) / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
    self.view.layoutIfNeeded()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.view.layoutIfNeeded()
    self.progressWidthConstraint.constant = pageNumber / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
    UIView.animate(withDuration: StylingConfig.progressBarAnimationDuration, delay: StylingConfig.progressBarAnimationDelay, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  func restoreGettingStartedState() {
    self.images = self.detachedProfile.images.map({ $0.gettingStartedImageContainer(size: .thumbnail) })
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
      let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
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
  
  func openPhotoBank(){
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
      
      if let image = self.images[indexPath.row].image {
        cell.imageView.image = image
      }else if let urlString = self.images[indexPath.row].imageContainer?.thumbnail.imageURL,  let imageURL = URL(string: urlString) {
        cell.imageView.image = nil
        cell.imageView.sd_setImage(with: imageURL, placeholderImage: nil, options: .highPriority, progress: nil, completed: nil)
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
      let gettingStartedImage = pickedImage.gettingStartedImage(size: .original)
      self.images.append(gettingStartedImage)
      self.collectionView.reloadData()
      ImageUploadAPI.shared.uploadNewImage(with: pickedImage, userID: userID) { result in
        switch result {
        case .success( let imageAllSizesRepresentation):
          print("Uploaded Image Successfully")
          gettingStartedImage.imageContainer = imageAllSizesRepresentation
        case .failure:
          print("Failed Uploading Image")
        }
        
      }
    }
    picker.dismiss(animated: true, completion: nil)
  }
  
}
