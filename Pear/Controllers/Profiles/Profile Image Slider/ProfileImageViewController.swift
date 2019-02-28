//
//  ProfileImageViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/13/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class ProfileImageViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!

    var images: [UIImage]!
    @IBOutlet weak var pageControl: UIPageControl!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(images: [UIImage]) -> ProfileImageViewController? {
        let storyboard = UIStoryboard(name: String(describing: ProfileImageViewController.self), bundle: nil)
        guard let profileImageVC = storyboard.instantiateInitialViewController() as? ProfileImageViewController else { return nil }
        profileImageVC.images = images
        return profileImageVC
    }

}

// MARK: - Life Cycle
extension ProfileImageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupScrollView()
    }

    func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        for imageNumber in 0..<self.images.count {
            let image = self.images[imageNumber]
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            imageView.image = image
            self.scrollView.addSubview(imageView)

            self.scrollView.addConstraints([
                    NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self.scrollView, attribute: .centerX, multiplier: 1 + CGFloat(imageNumber * 2), constant: 0.0),
                    NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self.scrollView, attribute: .centerY, multiplier: 1, constant: 0.0),
                    NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: self.scrollView, attribute: .width, multiplier: 1, constant: 0.0),
                    NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: self.scrollView, attribute: .height, multiplier: 1, constant: 0.0)
                ])
        }

        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * CGFloat(self.images.count), height: self.scrollView.frame.height)
        pageControl.numberOfPages = self.images.count
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(ProfileImageViewController.pageControlChanged(sender:)), for: .valueChanged)
        scrollView.delegate = self
    }

}

// MARK: - @IBAction
extension ProfileImageViewController {
    @objc func pageControlChanged(sender: UIPageControl) {
        let pageIndex: Int = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        if sender.currentPage != pageIndex {
            scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.width * CGFloat(sender.currentPage), y: 0), animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension ProfileImageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }

}
