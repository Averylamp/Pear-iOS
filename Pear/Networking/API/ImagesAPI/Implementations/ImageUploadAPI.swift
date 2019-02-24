//
//  ImageUploadAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import Foundation

class ImageUploadAPI:ImageAPI  {
    
    static let shared = ImageUploadAPI()
    
    private init(){
        
    }
    
    func uploadNewImage(with image: UIImage, completion: @escaping (Result<ImageAllSizesRepresentation, ImageAPIError>) -> Void) {
        
        
        let headers:[String: String] = [
            "Content-Type": "application/json",
//            "Content-Type": "application/x-www-form-urlencoded",
        ]
    
        let request = NSMutableURLRequest(url: NSURL(string: "\(Config.imageAPIHost)/upload_image")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 15.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        let imageString: String = image.jpegData(compressionQuality: 0.8)!.base64EncodedString()
        do {
            
            request.httpBody = try JSONSerialization.data(withJSONObject: ["image": imageString], options: .prettyPrinted)
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse)
                    if let data = data {
                        
                    }
                }
            })
            
            dataTask.resume()
        }catch{
//            completion( .failure(error))
        }
        
        
    }
    
    
    
    
}
