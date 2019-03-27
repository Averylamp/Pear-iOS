//
//  ImagesAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

enum ImageAPIError: Error {
  case failedDeserialization
  case unknownError(error: Error)
  case graphQLError(message: String)
}

protocol ImageAPI {
  func uploadNewImage(with image: UIImage, userID: String, completion: @escaping (Result<ImageContainer, ImageAPIError>) -> Void)
  func getImages(uid: String,
                 token: String,
                 completion: @escaping (Result<(displayedImages: [ImageContainer], imageBank: [ImageContainer]), ImageAPIError>) -> Void)
  func updateImages(userID: String,
                    displayedImages: [ImageContainer],
                    additionalImages: [ImageContainer],
                    completion: @escaping (Result<Bool, ImageAPIError>) -> Void)

}
