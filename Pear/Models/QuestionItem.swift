//
//  QuestionItem.swift
//  Pear
//
//  Created by Avery Lamp on 4/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

enum QuestionItemError: Error {
  case userNotAuthorized
  case missingEssentialInformation
}

enum QuestionItemKey: String, CodingKey {
  case documentID = "_id"
  case questionText
  case questionSubtext
  case questionTextWithName
  case questionType
  case suggestedResponses
  case placeholderResponseText
  case hiddenInQuestionnaire
  case hiddenInProfile
}

enum QuestionType: String {
  case multipleChoice
  case multipleChoiceWithOther
  case freeResponse
}

class QuestionItem: Decodable, GraphQLInput {
  
  var documentID: String?
  var questionText: String
  var questionSubtext: String?
  var questionTextWithName: String?
  var questionType: QuestionType
  var suggestedResponses: [QuestionSuggestedResponse]
  var placeholderResponseText: String?
  var hiddenInQuestionnaire: Bool
  var hiddenInProfile: Bool
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: QuestionItemKey.self)
    self.documentID = try? values.decode(String.self, forKey: .documentID)
    self.questionText = try values.decode(String.self, forKey: .questionText)
    self.questionSubtext = try? values.decode(String.self, forKey: .questionSubtext)
    self.questionTextWithName = try? values.decode(String.self, forKey: .questionTextWithName)
    guard let questionTypeString = try? values.decode(String.self, forKey: .questionType),
      let questionType = QuestionType(rawValue: questionTypeString) else {
        throw ContentItemError.decodingEnumError
    }
    self.questionType = questionType
    self.suggestedResponses = try values.decode([QuestionSuggestedResponse].self, forKey: .suggestedResponses)
    self.placeholderResponseText = try? values.decode(String.self, forKey: .placeholderResponseText)
    self.hiddenInQuestionnaire = try values.decode(Bool.self, forKey: .hiddenInQuestionnaire)
    self.hiddenInProfile = try values.decode(Bool.self, forKey: .hiddenInProfile)
  }
  
  init(documentID: String?,
       questionText: String,
       questionSubtext: String?,
       questionTextWithName: String?,
       questionType: QuestionType,
       suggestedResponses: [QuestionSuggestedResponse],
       placeholderResponseText: String?,
       hiddenInQuestionnaire: Bool,
       hiddenInProfile: Bool) {
    self.documentID = documentID
    self.questionText = questionText
    self.questionSubtext = questionSubtext
    self.questionTextWithName = questionTextWithName
    self.questionType = questionType
    self.suggestedResponses = suggestedResponses
    self.placeholderResponseText = placeholderResponseText
    self.hiddenInQuestionnaire = hiddenInQuestionnaire
    self.hiddenInProfile = hiddenInProfile
  }
  
  func toGraphQLInput() -> [String: Any] {
    var input: [String: Any] = [
      QuestionItemKey.questionText.rawValue: self.questionText,
      QuestionItemKey.questionType.rawValue: self.questionType.rawValue,
      QuestionItemKey.suggestedResponses.rawValue: self.suggestedResponses.map({ $0.toGraphQLInput()}),
      QuestionItemKey.hiddenInQuestionnaire.rawValue: self.hiddenInQuestionnaire,
      QuestionItemKey.hiddenInProfile.rawValue: self.hiddenInProfile
    ]
    if let documentID = self.documentID {
      input[QuestionItemKey.documentID.rawValue] = documentID
    }
    if let questionSubtext = self.questionSubtext {
      input[QuestionItemKey.questionSubtext.rawValue] = questionSubtext
    }
    if let questionTextWithName = self.questionTextWithName {
      input[QuestionItemKey.questionTextWithName.rawValue] = questionTextWithName
    }
    if let placeholderResponseText = self.placeholderResponseText {
      input[QuestionItemKey.placeholderResponseText.rawValue] = placeholderResponseText
    }
    return input
  }
  
  static func vibeQuestion() -> QuestionItem {
    
    return QuestionItem(documentID: "5cb1af368eb7800f51c00bbf",
                        questionText: "What's their vibe?",
                        questionSubtext: "Pick up to 3",
                        questionTextWithName: "What's <name> vibe?",
                        questionType: .multipleChoice,
                        suggestedResponses: QuestionSuggestedResponse.vibeResponses(),
                        placeholderResponseText: nil,
                        hiddenInQuestionnaire: false,
                        hiddenInProfile: false)
  }
  
  static func idealDateQuestion() -> QuestionItem {
    return QuestionItem(documentID: "5cb1af46951e460f2b486292",
                        questionText: "What time's their ideal date?",
                        questionSubtext: nil,
                        questionTextWithName: "What time's <name>'s ideal date?",
                        questionType: .multipleChoice,
                        suggestedResponses: QuestionSuggestedResponse.idealDateResponses(),
                        placeholderResponseText: nil,
                        hiddenInQuestionnaire: false,
                        hiddenInProfile: false)
  }
  
  static func dayOffQuestion() -> QuestionItem {
    return QuestionItem(documentID: "5cb1af55d94e960f442d2a60",
                        questionText: "What do they do on a day off?",
                        questionSubtext: nil,
                        questionTextWithName: "What do they do on a day off?",
                        questionType: .multipleChoice,
                        suggestedResponses: QuestionSuggestedResponse.dayOffResponses(),
                        placeholderResponseText: nil,
                        hiddenInQuestionnaire: false,
                        hiddenInProfile: false)
  }
  
}

enum ColorKey: String, CodingKey {
  case red
  case green
  case blue
  case alpha
}

class Color: Codable, GraphQLInput {
  
  var red: CGFloat
  var green: CGFloat
  var blue: CGFloat
  var alpha: CGFloat
  
  init?(color: UIColor?) {
    guard let color = color else {
      return nil
    }
    self.red = color.rgba.red
    self.green = color.rgba.green
    self.blue = color.rgba.blue
    self.alpha = color.rgba.alpha
  }
  
  func toGraphQLInput() -> [String: Any] {
    return [
      ColorKey.red.rawValue: self.red,
      ColorKey.green.rawValue: self.green,
      ColorKey.blue.rawValue: self.blue,
      ColorKey.alpha.rawValue: self.alpha
    ]
  }
  
  func uiColor() -> UIColor {
    return UIColor(red: self.red,
                   green: self.green,
                   blue: self.blue,
                   alpha: self.alpha)
  }
  
}

enum IconAssetKey: String, CodingKey {
  case assetString
  case assetURL
}

class IconAsset: Decodable, GraphQLInput {
  
  var assetString: String?
  var assetURL: URL?
  var cachedImage: UIImage?
  
  init (assetString: String?,
        assetURL: URL?
    ) {
    self.assetString = assetString
    self.assetURL = assetURL
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: IconAssetKey.self)
    self.assetString = try? values.decode(String.self, forKey: .assetString)
    if let assetURLString = try? values.decode(String.self, forKey: .assetURL),
      let assetURL = URL(string: assetURLString) {
      self.assetURL = assetURL
    } else {
      self.assetURL = nil
    }
    self.cachedImage = self.syncUIImageFetch()
    if self.cachedImage == nil {
      self.asyncUIImageFetch { (image) in
        if let image = image {
          self.cachedImage = image
        }
      }
    }
  }
  
  func syncUIImageFetch() -> UIImage? {
    if let assetString = self.assetString,
      let image = UIImage(named: assetString) {
      return image
    }
    return nil
  }
  
  func asyncUIImageFetch(foundImage:@escaping (UIImage?) -> Void) {
    if let assetString = self.assetString,
      let image = UIImage(named: assetString) {
      foundImage(image)
      return
    }
    if let assetURL = self.assetURL {
      SDWebImageDownloader.shared.downloadImage(with: assetURL) { (image, _, error, _) in
        if let error = error {
          print("Failed fetching image: \(error)")
        }
        if let image = image {
          foundImage(image)
        } else {
          foundImage(nil)
        }
      }
    } else {
      foundImage(nil)
    }
  }
  
  func assetLikelyExists() -> Bool {
    return self.assetString != nil || self.assetURL != nil
  }
  
  func toGraphQLInput() -> [String: Any] {
    return [
      IconAssetKey.assetString.rawValue: self.assetString as Any,
      IconAssetKey.assetURL.rawValue: self.assetURL as Any
    ]
  }
  
}
