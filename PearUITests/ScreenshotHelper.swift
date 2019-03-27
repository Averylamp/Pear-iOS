//
//  ScreenshotHelper.swift
//  PearUITests
//
//  Created by Avery Lamp on 3/26/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

// swiftlint:disable line_length

import XCTest

class ScreenshotHelper: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    
    let app = XCUIApplication()
    app.launchArguments = ["--uitesting"]
    
    addUIInterruptionMonitor(withDescription: "“Pear” Wants to Use “facebook.com” to Sign In") { (alert) -> Bool in
      print("========= Interruption Triggered\n\n\n")
      alert.buttons["Continue"].tap()
      return true
    }
    
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    app.launch()
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    //      ScreenshotHelper.deleteMyApp()
  }
  
  func testExample() {
    
    let app = XCUIApplication()
    
    app.buttons["Continue with Facebook"].tap()
//    app.alerts["“Pear” Wants to Use “facebook.com” to Sign In"].buttons["Continue"].tap()
//
//    if app.webViews.buttons["Continue"].exists {
//      app.webViews/*@START_MENU_TOKEN@*/.buttons["Continue"]/*[[".otherElements[\"Confirm Login\"]",".otherElements[\"main\"].buttons[\"Continue\"]",".buttons[\"Continue\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
//    } else {
//      let webViewsQuery = app.webViews
//      webViewsQuery/*@START_MENU_TOKEN@*/.textFields["Mobile number or email"]/*[[".otherElements[\"Log into Facebook | Facebook\"]",".otherElements[\"main\"].textFields[\"Mobile number or email\"]",".textFields[\"Mobile number or email\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
//      webViewsQuery/*@START_MENU_TOKEN@*/.textFields["Mobile number or email"]/*[[".otherElements[\"Log into Facebook | Facebook\"]",".otherElements[\"main\"].textFields[\"Mobile number or email\"]",".textFields[\"Mobile number or email\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.typeText("joel_ajkdqav_aguero@tfbnw.net\tfakeuserjoel")
//      webViewsQuery/*@START_MENU_TOKEN@*/.buttons["Log In"]/*[[".otherElements[\"Log into Facebook | Facebook\"]",".otherElements[\"main\"].buttons[\"Log In\"]",".buttons[\"Log In\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
//      webViewsQuery/*@START_MENU_TOKEN@*/.buttons["Continue"]/*[[".otherElements[\"Confirm Login\"]",".otherElements[\"main\"].buttons[\"Continue\"]",".buttons[\"Continue\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
//    }
//
//    app.tables.children(matching: .cell).element(boundBy: 1).children(matching: .other).element(boundBy: 0).swipeUp()
//    app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .scrollView).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).swipeUp()
//
  }
  
}
