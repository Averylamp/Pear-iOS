//
//  GetStartedPhotoInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedPhotoInputViewController: UIViewController {

    var gettingStartedData: GettingStartedData!

    @IBOutlet weak var iconImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var welcomeTitleLabel: UILabel!

    @IBOutlet weak var subtextLabel: UILabel!
    @IBOutlet weak var reviewProfileButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    let betweenImageSpacing: CGFloat = 6
    var images: [GettingStartedUIImage] = []
    let imagePickerController = UIImagePickerController()
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    var justMovedIndexPath: IndexPath?

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GettingStartedData) -> GetStartedPhotoInputViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedPhotoInputViewController.self), bundle: nil)
        guard let photoInputVC = storyboard.instantiateInitialViewController() as? GetStartedPhotoInputViewController else { return nil }
        photoInputVC.gettingStartedData = gettingStartedData
        return photoInputVC
    }

    func saveImages() {
        self.gettingStartedData.profileData.images = self.images
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.saveImages()

        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        self.saveImages()
        if self.gettingStartedData.profileData.images.count == 0 {
            self.alert(title: "Missing 🎑", message: "Please add at least one image of your friend")
            return
        }
        guard let profileReviewVC = GetStartedProfileReviewViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
            print("Failed to create profile Review VC")
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
        self.insertNamesIntoIntro()
        self.stylizeProfileButton()
        self.setupCollectionView()
        imagePickerController.delegate = self
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GetStartedPhotoInputViewController.handleLongGesture(gesture:)))
        self.collectionView.addGestureRecognizer(self.longPressGestureRecognizer)
        if self.view.frame.height < 600 {
            self.iconImageViewWidthConstraint.constant = 0
            self.view.layoutIfNeeded()
        }

    }
    func insertNamesIntoIntro() {
        self.welcomeTitleLabel.text = "Welcome to Pear,\n\(self.gettingStartedData.userFirstName!)"
        self.subtextLabel.text =  "Your profile for \(self.gettingStartedData.profileData.firstName) is coming along great. Help them strut their stuff by uploading a few photos."
    }

    func restoreGettingStartedState() {
        self.images = self.gettingStartedData.profileData.images
    }

    func stylizeProfileButton() {
        self.reviewProfileButton.layer.cornerRadius = 8
        self.reviewProfileButton.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 0.1)
        self.reviewProfileButton.layer.shadowOpacity = 0.1
        self.reviewProfileButton.layer.shadowColor = UIColor.black.cgColor
        self.reviewProfileButton.layer.shadowRadius = 2
        self.reviewProfileButton.layer.shadowOffset = CGSize(width: 1, height: 1)

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
            let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera()
            }))

            alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
                self.openGallery()
            }))

            alert.addAction(UIAlertAction(title: "Facebook", style: .default, handler: { _ in
                self.openGallery()
            }))

            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }
    }

    func openCamera() {
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            imagePickerController.sourceType = UIImagePickerController.SourceType.camera
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openGallery() {
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }

}

// MARK: - UICollectionViewDelegate Reordering
extension GetStartedPhotoInputViewController {

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return indexPath.item < self.images.count
    }

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        if proposedIndexPath.item >= self.images.count {
            return originalIndexPath
        }
        return proposedIndexPath
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("Moving item at index \(sourceIndexPath.item) to \(destinationIndexPath.item)")
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
        print(self.images)
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
        return 9
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.item < self.images.count {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageUploadCollectionViewCell", for: indexPath) as? ImageUploadCollectionViewCell else {
                return UICollectionViewCell()
            }
            print("Reloading cell: \(indexPath.item)")
            cell.imageView.image = self.images[indexPath.item]
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

// MARK: - UIPickerControllerDelegate
extension GetStartedPhotoInputViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let gettingStartedImage = pickedImage.gettingStartedImage()
            self.images.append(gettingStartedImage)
            self.collectionView.reloadData()
            ImageUploadAPI.shared.uploadNewImage(with: gettingStartedImage) { result in
                print("Image upload returned")
                switch result {
                case .success( let imageAllSizesRepresentation):
                    print("Finished properly")
                    print(imageAllSizesRepresentation)
                case .failure(let error):
                    print("Failed image api request")
                    print(error)
                }

            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

}
