//
//  ImageUploadAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class ImageUploadAPI: ImageAPI {

    static let shared = ImageUploadAPI()

    private init() {

    }

    func uploadNewImage(with image: UIImage, completion: @escaping (Result<ImageAllSizesRepresentation, ImageAPIError>) -> Void) {

        let headers: [String: String] = [
            "Content-Type": "application/json"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.imageAPIHost)/upload_image")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 15.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        let imageString: String = image.jpegData(compressionQuality: 0.8)!.base64EncodedString()
        do {

            request.httpBody = try JSONSerialization
                .data(withJSONObject: ["image": imageString], options: .prettyPrinted)

            let session = URLSession.shared
            let dataTask = session
                .dataTask(with: request as URLRequest, completionHandler: { (data, _, error) -> Void in
                if error != nil {
                    print(error as Any)
                } else {
                    if let data = data, let json = JSON(rawValue: data), let sizeMap = json["size_map"].dictionary {
                        var original: ImageSizeRepresentation?
                        var large: ImageSizeRepresentation?
                        var medium: ImageSizeRepresentation?
                        var small: ImageSizeRepresentation?
                        var thumb: ImageSizeRepresentation?
                        for (sizeType, sizeData) in sizeMap {
                            if let imageID = sizeData["imageID"].string,
                                let imageURL = sizeData["imageURL"].url,
                                let imageSize = sizeData["imageSize"].dictionary,
                                let imageWidth = imageSize["width"]?.int,
                                let imageHeight = imageSize["height"]?.int {
                                let imageSizeRep =
                                    ImageSizeRepresentation(imageID: imageID,
                                                            imageSize: ImageSize(rawValue: sizeType) ?? .unknown,
                                                            publicURL: imageURL,
                                                            height: imageHeight,
                                                            width: imageWidth)
                                switch sizeType {
                                case "original":
                                    original = imageSizeRep
                                case "large":
                                    large = imageSizeRep
                                case "medium":
                                    medium = imageSizeRep
                                case "small":
                                    small = imageSizeRep
                                case "thumb":
                                    thumb = imageSizeRep
                                default:
                                    print("Strange size detected")
                                }
                            }
                        }
                        guard let originalImageRep = original else { return }
                        guard let largeImageRep = large else { return }
                        guard let mediumImageRep = medium else { return }
                        guard let smallImageRep = small else { return }
                        guard let thumbImageRep = thumb else { return }

                        guard let allImageSizesRep  = ImageAllSizesRepresentation(original: originalImageRep,
                                                                            large: largeImageRep,
                                                                            medium: mediumImageRep,
                                                                            small: smallImageRep,
                                                                            thumbnail: thumbImageRep) else {
                                                                                print("Mismatching image ids")
                                                                                return
                        }

                        completion(.success(allImageSizesRep))

                        print(json)
                    }
                }
            })

            dataTask.resume()
        } catch {
//            completion( .failure(error))
        }

    }

}
