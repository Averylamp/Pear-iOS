//
//  ImageAPITests.swift
//  PearTests
//
//  Created by Avery Lamp on 3/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import XCTest
@testable import Pear

class ImageAPITests: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  func testImageUpload() {
    let promise = expectation(description: "Upload Successful")
    if let testImage = R.image.sampleProfileErika1() {
      let testUserID = "5c82162afec46c84e924a332"
      ImageUploadAPI.shared.uploadNewImage(with: testImage, userID: testUserID, test: true) { (result) in
        print("Image upload returned")
        switch result {
        case .success:
          print("Finished Image Test Successfully")
          promise.fulfill()
        case .failure(let error):
          print("Failed image api request")
          print(error)
          XCTFail("\(error.localizedDescription)")
        }
      }
    } else {
      XCTFail("Failed to create image for image upload test")
    }
    waitForExpectations(timeout: 15, handler: nil)
  }
  
}
