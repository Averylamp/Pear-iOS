//
//  QuestionSuggestedResponse.swift
//  Pear
//
//  Created by Avery Lamp on 4/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
enum QuestionSuggestedResponseKey: String, CodingKey {
  case responseBody
  case responseTitle
  case color
  case icon
}

class QuestionSuggestedResponse: Decodable, GraphQLInput, GraphQLDecodable, Equatable {
  
  static func == (lhs: QuestionSuggestedResponse, rhs: QuestionSuggestedResponse) -> Bool {
    return lhs.responseBody == rhs.responseBody &&
           lhs.responseTitle == rhs.responseTitle &&
           lhs.color == rhs.color &&
           lhs.icon == rhs.icon
  }
  
  var responseBody: String
  var responseTitle: String?
  var color: Color?
  var icon: IconAsset?
  
  static func graphQLAllFields() -> String {
    return "{ responseBody responseTitle color \(Color.graphQLAllFields()) icon \(IconAsset.graphQLAllFields()) }"
  }
  
  func toGraphQLInput() -> [String: Any] {
    var input: [String: Any] = [
      QuestionSuggestedResponseKey.responseBody.rawValue: self.responseBody
    ]
    if let responseTitle = self.responseTitle {
      input[QuestionSuggestedResponseKey.responseTitle.rawValue] = responseTitle
    }
    if let color = self.color {
      input[QuestionSuggestedResponseKey.color.rawValue] = color.toGraphQLInput()
    }
    if let icon = self.icon {
      input[QuestionSuggestedResponseKey.icon.rawValue] = icon.toGraphQLInput()
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
  
  static func idealDateResponses() -> [QuestionSuggestedResponse] {
    var responses: [QuestionSuggestedResponse] = []
    responses.append(QuestionSuggestedResponse(responseBody: "How’d they wake up this early? (Or was this from the night before ¯\\_(ツ)_/¯)",
                                               responseTitle: "8am", color: nil, icon: nil))
    responses.append(QuestionSuggestedResponse(responseBody: "a late breakfast",
                                               responseTitle: "11am", color: nil, icon: nil))
    responses.append(QuestionSuggestedResponse(responseBody: "casual coffee",
                                               responseTitle: "3pm", color: nil, icon: nil))
    responses.append(QuestionSuggestedResponse(responseBody: "classy dinner",
                                               responseTitle: "6pm", color: nil, icon: nil))
    responses.append(QuestionSuggestedResponse(responseBody: "so wyd 😝",
                                               responseTitle: "1am", color: nil, icon: nil))
    return responses
  }
  
  static func dayOffResponses() -> [QuestionSuggestedResponse] {
    var responses: [QuestionSuggestedResponse] = []
    responses.append(QuestionSuggestedResponse(responseBody: "Eat a bunch of food at home",
                                               responseTitle: nil, color: nil, icon: nil))
    responses.append(QuestionSuggestedResponse(responseBody: "Sleep a bunch of food at home",
                                               responseTitle: nil, color: nil, icon: nil))
    responses.append(QuestionSuggestedResponse(responseBody: "Dream a bunch of food at home",
                                               responseTitle: nil, color: nil, icon: nil))
    responses.append(QuestionSuggestedResponse(responseBody: "🍷🍷🍷🍷🍷🍷🍷🍷🍷🍷",
                                               responseTitle: nil, color: nil, icon: nil))
    
    return responses
  }
}
