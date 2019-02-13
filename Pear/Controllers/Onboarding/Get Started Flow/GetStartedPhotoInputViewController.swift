//
//  GetStartedPhotoInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedPhotoInputViewController: UIViewController {
    
    var endorsement: Endorsement!
    
    @IBOutlet weak var welcomeTitleLabel: UILabel!
    
    @IBOutlet weak var subtextLabel: UILabel!
    @IBOutlet weak var reviewProfileButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let betweenImageSpacing: CGFloat = 6
    var images: [UIImage] = []
    let imagePickerController = UIImagePickerController()
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(endorsement: Endorsement) -> GetStartedPhotoInputViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedPhotoInputViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedPhotoInputViewController
        vc.endorsement = endorsement
        return vc
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        let createAccountVC = GetStartedCreateAccountViewController.instantiate(endorsement: self.endorsement)
        self.navigationController?.pushViewController(createAccountVC, animated: true)
    }
    
}


// MARK: - Life Cycle
extension GetStartedPhotoInputViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stylizeProfileButton()
        self.setupCollectionView()
        imagePickerController.delegate = self
    }
    
    
    func stylizeProfileButton(){
        self.reviewProfileButton.layer.cornerRadius = 8
        self.reviewProfileButton.layer.borderWidth = 1.0
        self.reviewProfileButton.layer.borderColor = UIColor(red:0.07, green:0.07, blue:0.07, alpha:0.1).cgColor
        self.reviewProfileButton.layer.shadowOpacity = 0.1
        self.reviewProfileButton.layer.shadowColor = UIColor.black.cgColor
        self.reviewProfileButton.layer.shadowRadius = 2
        self.reviewProfileButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        
    }
    
    func setupCollectionView(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
}

// MARK: - UICollectionViewDelegate
extension GetStartedPhotoInputViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected Item")
        if indexPath.item >= self.images.count {
            
            let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera()
            }))
            
            alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
                self.openGallery()
            }))
            
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
    {
        imagePickerController.sourceType = UIImagePickerController.SourceType.camera
    imagePickerController.allowsEditing = true
    self.present(imagePickerController, animated: true, completion: nil)
    }
    else
    {
    let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
    }
    }
   
    func openGallery(){
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)

    }
    
}


// MARK: - UICollectionViewDataSource
extension GetStartedPhotoInputViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item < self.images.count{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageUploadCollectionViewCell", for: indexPath) as! ImageUploadCollectionViewCell
            cell.imageView.image = self.images[indexPath.item]
            cell.imageView.contentMode = .scaleAspectFill
            cell.imageView.layer.cornerRadius = 3
            cell.imageView.clipsToBounds = true
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageUploadAddCollectionViewCell", for: indexPath) as! ImageUploadAddCollectionViewCell
            
            return cell
        }
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
extension GetStartedPhotoInputViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.images.append(pickedImage)
            self.collectionView.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)

    }
    
}
