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
    
    return QuestionItem(documentID: nil,
                        questionText: "What's their vibe?",
                        questionSubtext: "Pick up to 3",
                        questionTextWithName: "What's <name> vibe?",
                        questionType: .multipleChoice,
                        suggestedResponses: QuestionSuggestedResponse.vibeResponses(),
                        placeholderResponseText: nil,
                        hiddenInQuestionnaire: false,
                        hiddenInProfile: false)
  }
  
}

enum QuestionSuggestedResponseKey: String, CodingKey {
  case responseBody
  case responseTitle
  case color
  case icon
}

class QuestionSuggestedResponse: Decodable, GraphQLInput {
  
  var responseBody: String
  var responseTitle: String?
  var color: Color?
  var icon: IconAsset?
  
  func toGraphQLInput() -> [String: Any] {
    var input: [String: Any] = [
      QuestionSuggestedResponseKey.responseBody.rawValue: self.responseBody
    ]
    if let responseTitle = self.responseTitle {
      input[QuestionSuggestedResponseKey.responseTitle.rawValue] = responseTitle
    }
    if let color = self.color {
      input[QuestionSuggestedResponseKey.color.rawValue] = color
    }
    if let icon = self.icon {
      input[QuestionSuggestedResponseKey.icon.rawValue] = icon
    }
    return input
  }
  
  init(responseBody: String,
       responseTitle: String?,
       color: Color?,
       icon: IconAsset?) {
    self.responseBody = responseBody
    self.responseTitle = responseTitle
    self.color = color
    self.icon = icon
  }
 
  static func vibeResponses() -> [QuestionSuggestedResponse] {
    var responses: [QuestionSuggestedResponse] = []
    
    responses.append(QuestionSuggestedResponse(responseBody: "Player", responseTitle: nil,
                                               color: Color(color: R.color.vibePlayerColor()),
                                               icon: IconAsset(assetString: R.image.vibeIconPlayer.name, assetURL: nil)))
    responses.append(QuestionSuggestedResponse(responseBody: "Fineapple", responseTitle: nil,
                                               color: Color(color: R.color.vibeFineappleColor()),
                                               icon: IconAsset(assetString: R.image.vibeIconFineapple.name, assetURL: nil)))
    responses.append(QuestionSuggestedResponse(responseBody: "Forbidden Fruit", responseTitle: nil,
                                               color: Color(color: R.color.vibeForbiddenFruitColor()),
                                               icon: IconAsset(assetString: R.image.vibeIconForbiddenFruit.name, assetURL: nil)))
    responses.append(QuestionSuggestedResponse(responseBody: "Just Add Water", responseTitle: nil,
                                               color: Color(color: R.color.vibeJustAddWaterColor()),
                                               icon: IconAsset(assetString: R.image.vibeIconJustAddWater.name, assetURL: nil)))
    responses.append(QuestionSuggestedResponse(responseBody: "Cherry Bomb", responseTitle: nil,
                                               color: Color(color: R.color.vibeCherryBombColor()),
                                               icon: IconAsset(assetString: R.image.vibeIconCherryBomb.name, assetURL: nil)))
    responses.append(QuestionSuggestedResponse(responseBody: "Coco-NUTS", responseTitle: nil,
                                               color: Color(color: R.color.vibeCoconutsColor()),
                                               icon: IconAsset(assetString: R.image.vibeIconCoconuts.name, assetURL: nil)))
    responses.append(QuestionSuggestedResponse(responseBody: "Extra Like Guac", responseTitle: nil,
                                               color: Color(color: R.color.vibeExtraLikeGuacColor()),
                                               icon: IconAsset(assetString: R.image.vibeIconExtraLikeGuac.name, assetURL: nil)))
    responses.append(QuestionSuggestedResponse(responseBody: "Passionfruit", responseTitle: nil,
                                               color: Color(color: R.color.vibePassionfruitColor()),
                                               icon: IconAsset(assetString: R.image.vibeIconPassionfruit.name, assetURL: nil)))
    responses.append(QuestionSuggestedResponse(responseBody: "Spicy", responseTitle: nil,
                                               color: Color(color: R.color.vibeSpicyColor()),
                                               icon: IconAsset(assetString: R.image.vibeIconSpicy.name, assetURL: nil)))
    responses.append(QuestionSuggestedResponse(responseBody: "Big Gains", responseTitle: nil,
                                               color: Color(color: R.color.vibeBigGainsColor()),
                                               icon: IconAsset(assetString: R.image.vibeIconBigGains.name, assetURL: nil)))
    responses.append(QuestionSuggestedResponse(responseBody: "Baddest Radish", responseTitle: nil,
                                               color: Color(color: R.color.vibeBaddestRadishColor()),
                                               icon: IconAsset(assetString: R.image.vibeIconBaddestRadish.name, assetURL: nil)))

    return responses
  }
  
}

enum QuestionResponseItemKey: String, CodingKey {
  case documentID = "_id"
  case authorID = "author_id"
  case authorFirstName
  case questionID = "question_id"
  case question
  case responseBody
  case responseTitle
  case color
  case icon
  case hidden
}

class QuestionResponseItem: Decodable, GraphQLInput {
  func toGraphQLInput() -> [String: Any] {
    var input: [String: Any] = [
      QuestionResponseItemKey.authorID.rawValue: authorID,
      QuestionResponseItemKey.authorFirstName.rawValue: authorFirstName,
      QuestionResponseItemKey.questionID.rawValue: questionID,
      QuestionResponseItemKey.question.rawValue: question.toGraphQLInput(),
      QuestionResponseItemKey.responseBody.rawValue: responseBody,
      QuestionResponseItemKey.hidden.rawValue: hidden
    ]
    if let documentID = self.documentID {
      input[QuestionResponseItemKey.documentID.rawValue] = documentID
    }
    if let responseTitle = self.responseTitle {
      input[QuestionResponseItemKey.responseTitle.rawValue] = responseTitle
    }
    if let color = self.color {
      input[QuestionResponseItemKey.color.rawValue] = color
    }
    if let icon = self.icon {
      input[QuestionResponseItemKey.icon.rawValue] = icon
    }
    return input
  }
  
  var documentID: String?
  var authorID: String
  var authorFirstName: String
  var questionID: String
  var question: QuestionItem
  var responseBody: String
  var responseTitle: String?
  var color: Color?
  var icon: IconAsset?
  var hidden: Bool
  
  init( documentID: String?,
        question: QuestionItem,
        responseBody: String,
        responseTitle: String?,
        color: Color?,
        icon: IconAsset?) throws {
    
    self.documentID = documentID
    guard let creatorID = DataStore.shared.currentPearUser?.documentID,
      let creatorFirstName = DataStore.shared.currentPearUser?.firstName else {
        throw QuestionItemError.userNotAuthorized
    }
    self.authorID = creatorID
    self.authorFirstName = creatorFirstName
    guard let questionID = question.documentID else {
      print("Question without ID cant be saved")
      throw QuestionItemError.missingEssentialInformation
    }
    self.questionID = questionID
    self.question = question
    self.responseBody = responseBody
    self.responseTitle = responseTitle
    self.color = color
    self.icon = icon
    self.hidden = false
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: QuestionResponseItemKey.self)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.authorID = try values.decode(String.self, forKey: .authorID)
    self.authorFirstName = try values.decode(String.self, forKey: .authorFirstName)
    self.questionID = try values.decode(String.self, forKey: .questionID)
    self.question = try values.decode(QuestionItem.self, forKey: .question)
    self.responseBody = try values.decode(String.self, forKey: .responseBody)
    self.responseTitle = try? values.decode(String.self, forKey: .responseTitle)
    self.color = try? values.decode(Color.self, forKey: .color)
    self.icon = try? values.decode(IconAsset.self, forKey: .icon)
    self.hidden = try values.decode(Bool.self, forKey: .hidden)
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
