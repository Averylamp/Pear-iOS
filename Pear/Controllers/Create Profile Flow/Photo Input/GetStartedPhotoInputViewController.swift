//
//  GetStartedPhotoInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos

class GetStartedPhotoInputViewController: UIViewController {
  
  var gettingStartedUserProfileData: UserProfileCreationData!
  
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
  let pageNumber: CGFloat = 7.0
  
  let betweenImageSpacing: CGFloat = 6
  var images: [GettingStartedUIImageContainer] = []
  var imagePickerController = BSImagePickerViewController()
  var longPressGestureRecognizer: UILongPressGestureRecognizer!
  var justMovedIndexPath: IndexPath?
  var imageReplacementIndexPath: IndexPath?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(gettingStartedData: UserProfileCreationData) -> GetStartedPhotoInputViewController? {
    let storyboard = UIStoryboard(name: String(describing: GetStartedPhotoInputViewController.self), bundle: nil)
    guard let photoInputVC = storyboard.instantiateInitialViewController() as? GetStartedPhotoInputViewController else { return nil }
    photoInputVC.gettingStartedUserProfileData = gettingStartedData
    return photoInputVC
  }
  
  func saveImages() {
    self.gettingStartedUserProfileData.images = self.images
  }
  
  @IBAction func cancelButtonClicked(_ sender: Any) {
    let alertController = UIAlertController(title: "Stop Making a Profile?", message: "Are you sure you want to cancel", preferredStyle: .alert)
    let continueAction = UIAlertAction(title: "Keep Going", style: .default, handler: nil)
    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
      DispatchQueue.main.async {
        guard let mainVC = LoadingScreenViewController.getMainScreenVC() else {
          print("Failed to initialize Main VC")
          return
        }
        self.navigationController?.setViewControllers([mainVC], animated: true)
      }
    }
    alertController.addAction(continueAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.saveImages()
    
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.saveImages()
    
    guard let profileReviewVC = FullProfileReviewViewController.instantiate(gettingStartedUserProfileData: self.gettingStartedUserProfileData) else {
      print("Failed to create scrolling Full VC")
      return
    }
    self.navigationController?.pushViewController(profileReviewVC, animated: true)
    
  }
  
}

// MARK: - Life Cycle
extension GetStartedPhotoInputViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.restoreGettingStartedState()
    self.setupCollectionView()
    
    self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GetStartedPhotoInputViewController.handleLongGesture(gesture:)))
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
    self.images = self.gettingStartedUserProfileData.images
    
  }
  
  func setupCollectionView() {
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
  }
  
}

// MARK: - UICollectionViewDelegate
extension GetStartedPhotoInputViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.item >= self.images.count {
      self.imageReplacementIndexPath = nil
      self.pickImage()
    } else {
      let alertController = UIAlertController(title: "What would you like to do?", message: nil, preferredStyle: .actionSheet)
      let viewImageAction = UIAlertAction(title: "View Full Images", style: .default) { (_) in
        DispatchQueue.main.async {
//          var lightboxImages: [LightboxImage] = []
//          for image in self.images {
//            var lightboxImage: LightboxImage?
//            if let rawImage = image.image {
//              lightboxImage = LightboxImage(image: rawImage)
//            } else if let imageURLString = image.imageContainer?.large.imageURL,
//              let imageURL = URL(string: imageURLString) {
//              lightboxImage = LightboxImage(imageURL: imageURL)
//            }
//            if let lightboxImage = lightboxImage {
//              lightboxImages.append(lightboxImage)
//            }
//          }
//          if lightboxImages.count > 0 {
//            let index = indexPath.row < lightboxImages.count ? indexPath.row : lightboxImages.count - 1
//            let lightboxController = LightboxController(images: lightboxImages, startIndex: index)
//            lightboxController.dynamicBackground = false
//            self.present(lightboxController, animated: true, completion: nil)
//          }
        }
      }
      let replaceImageAction = UIAlertAction(title: "Replace Image", style: .default) { (_) in
        DispatchQueue.main.async {
          self.imageReplacementIndexPath = indexPath
          self.pickImage()
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      alertController.addAction(viewImageAction)
      alertController.addAction(replaceImageAction)
      alertController.addAction(cancelAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  func pickImage() {
    if UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
      if self.imageReplacementIndexPath != nil {
        self.imagePickerController.maxNumberOfSelections = 6 - self.images.count + 1
      } else {
        self.imagePickerController.maxNumberOfSelections = 6 - self.images.count
      }
      self.imagePickerController.takePhotos = true
      bs_presentImagePickerController(self.imagePickerController, animated: true, select: { (_) in
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
      }, deselect: nil, cancel: nil, finish: { (assets) in
        DispatchQueue.main.async {
          self.newPicturesSelected(assets: assets)
          self.imagePickerController = BSImagePickerViewController()
        }
      }, completion: nil)
    }
  }
  
}

// MARK: - UICollectionViewDelegate Reordering
extension GetStartedPhotoInputViewController {
  
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
extension GetStartedPhotoInputViewController: UICollectionViewDataSource, ImageUploadCollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 6
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if indexPath.item < self.images.count {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageUploadCollectionViewCell", for: indexPath) as? ImageUploadCollectionViewCell else {
        return UICollectionViewCell()
      }
      cell.imageView.image = self.images[indexPath.item].image
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
extension GetStartedPhotoInputViewController: UICollectionViewDelegateFlowLayout {
  
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

// MARK: QBImagePickerControllerDelegate
extension GetStartedPhotoInputViewController {
  
  func newPicturesSelected(assets: [PHAsset]) {
    print("\(assets.count) Selected Assets")
    for asset in assets {
      print(asset)
      if let pickedImage = self.getUIImage(asset: asset),
        let userID = DataStore.shared.currentPearUser?.documentID {
        print("Adding image to set")
        print(pickedImage.size)
        let loadingImageContainer = pickedImage.gettingStartedImage(size: .original)
        if let replacementIndex = self.imageReplacementIndexPath {
          self.images.remove(at: replacementIndex.row)
          self.images.insert(loadingImageContainer, at: replacementIndex.row)
          self.imageReplacementIndexPath = nil
        } else {
          self.images.append(loadingImageContainer)
        }
        self.collectionView.reloadData()
        PearImageAPI.shared.uploadNewImage(with: pickedImage, userID: userID) { result in
          switch result {
          case .success( let imageAllSizesRepresentation):
            print("Uploaded Image Successfully")
            loadingImageContainer.imageContainer = imageAllSizesRepresentation

          case .failure:
            print("Failed Uploading Image")
          }
          
        }
      }
    }
  }
  
  func getUIImage(asset: PHAsset) -> UIImage? {
    
    var img: UIImage?
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.version = .original
    options.isSynchronous = true
    manager.requestImageData(for: asset, options: options) { data, _, _, _ in
      if let data = data {
        img = UIImage(data: data)
      }
    }
    return img
  }
  
}
