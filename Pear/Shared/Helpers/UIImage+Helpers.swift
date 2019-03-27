//
//  UIImageExtensions.swift
//  Pear
//
//  Created by Avery Lamp on 2/11/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Accelerate

extension UIImage {
  func imageWith(newSize: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: newSize)
    let image = renderer.image { _ in
      self.draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
    }
    return image
  }
  
  func resizeImageUsingVImage(size: CGSize) -> UIImage? {
    let cgImage = self.cgImage!
    var format = vImage_CGImageFormat(bitsPerComponent: 8,
                                      bitsPerPixel: 32,
                                      colorSpace: nil,
                                      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                                      version: 0,
                                      decode: nil,
                                      renderingIntent: CGColorRenderingIntent.defaultIntent)
    var sourceBuffer = vImage_Buffer()
    defer {
        free(sourceBuffer.data)
    }
    var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
    guard error == kvImageNoError else { return nil }
    // create a destination buffer
    let scale = self.scale
    let destWidth = Int(size.width)
    let destHeight = Int(size.height)
    let bytesPerPixel = self.cgImage!.bitsPerPixel/8
    let destBytesPerRow = destWidth * bytesPerPixel
    let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
    defer {
      destData.deallocate()
    }
    var destBuffer = vImage_Buffer(data: destData,
                                   height: vImagePixelCount(destHeight),
                                   width: vImagePixelCount(destWidth),
                                   rowBytes: destBytesPerRow)
    // scale the image
    error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
    guard error == kvImageNoError else { return nil }
    // create a CGImage from vImage_Buffer
    var destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
    guard error == kvImageNoError else { return nil }
    // create a UIImage
    let resizedImage = destCGImage.flatMap { UIImage(cgImage: $0, scale: 0.0, orientation: self.imageOrientation) }
    destCGImage = nil
    return resizedImage
  }
  
  func gettingStartedImage(size: ImageType? = nil) -> GettingStartedUIImageContainer {
    return GettingStartedUIImageContainer(image: self, imageSize: size)
  }
}

