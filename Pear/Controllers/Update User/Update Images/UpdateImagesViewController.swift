//
//  UpdateImagesViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos

class UpdateImagesViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  var images: [LoadedImageContainer] = []
  var originalImages: [LoadedImageContainer] = []
  var imagePickerController = BSImagePickerViewController()
  var longPressGestureRecognizer: UILongPressGestureRecognizer!
  var justMovedIndexPath: IndexPath?
  var imageReplacementIndexPath: IndexPath?
  var allowsDelete: Bool = true
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(images: [LoadedImageContainer], allowsDelete: Bool = false) -> UpdateImagesViewController? {
    let storyboard = UIStoryboard(name: String(describing: UpdateImagesViewController.self), bundle: nil)
    guard let photoInputVC = storyboard.instantiateInitialViewController() as? UpdateImagesViewController else { return nil }
    photoInputVC.images = images
    photoInputVC.originalImages = images
    photoInputVC.allowsDelete = allowsDelete
    return photoInputVC
  }
  
}

// MARK: - Life Cycle
extension UpdateImagesViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupCollectionView()
    self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(UpdateImagesViewController.handleLongGesture(gesture:)))
    self.collectionView.addGestureRecognizer(self.longPressGestureRecognizer)
    self.stylize()
  }
  
  func stylize() {
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  func setupCollectionView() {
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
  }
}

// MARK: 

extension UpdateImagesViewController {
  
  func checkForChanges() -> Bool {
    if self.images.count != self.originalImages.count {
      return true
    }
    for index in 0..<self.images.count {
      if self.images[index].image != self.originalImages[index].image ||
        self.images[index].imageContainer?.imageID != self.originalImages[index].imageContainer?.imageID {
        return true
      }
    }
    return false
  }
  
}

// MARK: - UICollectionViewDelegate
extension UpdateImagesViewController: UICollectionViewDelegate {

  func selectedItemAtIndex(index: Int) {
    if index >= self.images.count {
      self.imageReplacementIndexPath = nil
      self.pickImage()
    } else {
      let alertController = UIAlertController(title: "What would you like to do?", message: nil, preferredStyle: .actionSheet)
      let replaceImageAction = UIAlertAction(title: "Replace Image", style: .default) { (_) in
        DispatchQueue.main.async {
          self.imageReplacementIndexPath = IndexPath(item: index, section: 0)
          self.pickImage()
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      alertController.addAction(replaceImageAction)
      alertController.addAction(cancelAction)
      self.present(alertController, animated: true, completion: nil)
    }

  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    self.selectedItemAtIndex(index: indexPath.item)
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
  
  func openCamera() {
    if UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
      self.imagePickerController.maxNumberOfSelections = 6 - self.images.count
      bs_presentImagePickerController(self.imagePickerController, animated: true, select: nil, deselect: nil, cancel: nil, finish: { (assets) in
        self.newPicturesSelected(assets: assets)
      }, completion: nil)
    } else {
      let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func openGallery() {
    self.imagePickerController.maxNumberOfSelections = 6 - self.images.count
    bs_presentImagePickerController(self.imagePickerController, animated: true, select: nil, deselect: nil, cancel: nil, finish: { (assets) in
      DispatchQueue.main.async {
        self.newPicturesSelected(assets: assets)
      }
    }, completion: nil)
  }
  
  func openPhotoBank() {
    self.alert(title: "Feature Unavailable", message: "This feature is currently unavailable, but will be released soon")
  }
  
}

// MARK: - UICollectionViewDelegate Reordering
extension UpdateImagesViewController {
  
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
extension UpdateImagesViewController: UICollectionViewDataSource, ImageUploadCollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 6
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if indexPath.item < self.images.count {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageUploadCollectionViewCell", for: indexPath) as? ImageUploadCollectionViewCell else {
        return UICollectionViewCell()
      }
      cell.cancelButton.isHidden = !self.allowsDelete
      if let image = self.images[indexPath.row].image {
        cell.imageView.image = image
      } else if let urlString = self.images[indexPath.row].imageContainer?.thumbnail.imageURL, let imageURL = URL(string: urlString) {
        cell.imageView.image = nil
        cell.imageView.sd_setImage(with: imageURL, placeholderImage: nil, options: .highPriority, progress: nil, completed: nil)
      }
      cell.imageView.contentMode = .scaleAspectFill
      cell.imageView.layer.cornerRadius = 3
      cell.imageView.clipsToBounds = true
      cell.imageCellDelegate = self
      cell.tag = indexPath.item
      cell.cancelButton.tag = indexPath.item
      return cell
    } else {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageUploadAddCollectionViewCell", for: indexPath) as? ImageUploadAddCollectionViewCell else {
        return UICollectionViewCell()
      }
      cell.tag = indexPath.item
      cell.imageCellDelegate = self
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
  
  func imageClicked(tag: Int) {
    self.selectedItemAtIndex(index: tag)
  }
  
}

// MARK: QBImagePickerController
extension UpdateImagesViewController {
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
    options.version = .current
    options.isSynchronous = true
    manager.requestImageData(for: asset, options: options) { data, _, _, _ in
      if let data = data {
        img = UIImage(data: data)
      }
    }
    return img
  }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension UpdateImagesViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let sideLength: CGFloat = collectionView.frame.size.width / 3.0
    return CGSize(width: sideLength, height: sideLength)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
}
