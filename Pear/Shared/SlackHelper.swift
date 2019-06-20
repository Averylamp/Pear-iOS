//
//  SlackHelper.swift
//  Pear
//
//  Created by Avery Lamp on 6/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class SlackHelper: NSObject {
  
  var userEvents: [SlackEvent] = []
  var startTime: Double = CACurrentMediaTime()
  
  struct SlackEvent {
    let text: String
    let color: String
  }
  
  static let shared = SlackHelper()
  
  private override init() {
    super.init()
    self.startNewSession()
  }
  
  func startNewSession() {
    self.userEvents = []
    self.startTime = CACurrentMediaTime()
  }
  
  func addEvent(text: String, color: UIColor = UIColor.black) {
    self.userEvents.append(SlackEvent(text: text, color: color.hexColor))
    if self.userEvents.count == 98 {
      self.userEvents.append(SlackEvent(text: "Too many events, continuing with a new session", color: UIColor.purple.hexColor))
      self.sendStory()
    }
  }
  
  func getAttachmentsFromEvents() -> [[String: Any]] {
    return userEvents.map({
      [
        "text": $0.text,
        "color": $0.color
      ]
    })
  }
  
  func sendStory() {
    #if DEVMODE
    return
    #endif
    
    let timePassed = CACurrentMediaTime() - self.startTime
    if timePassed < 15 || self.userEvents.count < 3 {
      return
    }
    if !DataStore.shared.remoteConfig.configValue(forKey: "slack_stores_enabled").boolValue {
      return
    }
    if let phoneNumber = DataStore.shared.currentPearUser?.phoneNumber {
      let skippedStoresData = DataStore.shared.remoteConfig.configValue(forKey: "slack_stores_skipped_phone_numbers").dataValue
      if let skippedPhoneNumberArray = try? JSON(data: skippedStoresData).array {
        let skippedPhoneNumbers = skippedPhoneNumberArray.compactMap({ $0.string })
        if skippedPhoneNumbers.contains(phoneNumber) {
          return
        }
      }
    }
    
    let sessionNumber = UserDefaults.standard.integer(forKey: UserDefaultKeys.userSessionNumber.rawValue)
    UserDefaults.standard.set(sessionNumber + 1, forKey: UserDefaultKeys.userSessionNumber.rawValue)
    var lastSessionString: String?
    if let lastSessionTime = DataStore.shared.fetchDateFromDefaults(flag: .userLastSlackStoryDate) {
      let hoursPassed = Date().timeIntervalSince(lastSessionTime) / 3600.0
      lastSessionString = "Last Slack Story: \(Double(Int(hoursPassed * 100)) / 100.0) hours ago"
      DataStore.shared.setDateToDefaults(flag: .userLastSlackStoryDate, date: Date())
    }
    if let user = DataStore.shared.currentPearUser {
      self.userEvents.insert(SlackEvent(text: user.toSlackStorySummary(profileStats: true, currentUserStats: true),
                                        color: UIColor.green.hexColor), at: 0)
    }
    self.userEvents.insert(SlackEvent(text: "______________________________________________\nSession Duration: \(Int(timePassed))s, Session Number: \(sessionNumber), Events: \(self.userEvents.count) \(lastSessionString != nil ? "\n\(lastSessionString!)" : "")", color: UIColor.purple.hexColor), at: 0)
    let urlString = "https://hooks.slack.com/services/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"
    let url = URL(string: urlString)
    let rawData: [String: Any] = [
      "attachments": self.getAttachmentsFromEvents()
    ]
    if let url = url,
      let data = try? JSONSerialization.data(withJSONObject: rawData, options: .prettyPrinted) {
      var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
      request.httpMethod = "POST"
      request.addValue("application/json", forHTTPHeaderField: "Content-type")
      request.httpBody = data
      let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
        if let error = error {
          print("Error sending story: \(error)")
        }
        if let data = data {
          print(data)
        }
        self.startNewSession()
      }
      dataTask.resume()
    }
    
  }
  
  // swiftlint:disable:next line_length
  let animalNames: [String] = ["Canidae", "Felidae", "Cat", "Cattle", "Dog", "Donkey", "Goat", "Horse", "Pig", "Rabbit", "Aardvark", "Aardwolf", "Albatross", "Alligator", "Alpaca", "Amphibian", "list", "Anaconda", "Angelfish", "Anglerfish", "Ant", "Anteater", "Antelope", "Antlion", "Ape", "Aphid", "Armadillo", "Asp", "Baboon", "Badger", "Bandicoot", "Barnacle", "Barracuda", "Basilisk", "Bass", "Bat", "Bear", "list", "Beaver", "Bedbug", "Bee", "Beetle", "Bird", "list", "Bison", "Blackbird", "Boa", "Boar", "Bobcat", "Bobolink", "Bonobo", "Booby", "Bovid", "Bug", "Butterfly", "Buzzard", "Camel", "Canid", "Capybara", "Cardinal", "Caribou", "Carp", "Cat", "list", "Catshark", "Caterpillar", "Catfish", "Cattle", "list", "Centipede", "Cephalopod", "Chameleon", "Cheetah", "Chickadee", "Chicken", "list", "Chimpanzee", "Chinchilla", "Chipmunk", "Clam", "Clownfish", "Cobra", "Cockroach", "Cod", "Condor", "Constrictor", "Coral", "Cougar", "Cow", "Coyote", "Crab", "Crane", "Crawdad", "Crayfish", "Cricket", "Crocodile", "Crow", "Cuckoo", "Cicada", "Damselfly", "Deer", "Dingo", "Dinosaur", "list", "Dog", "list", "Dolphin", "Donkey", "list", "Dormouse", "Dove", "Dragonfly", "Dragon", "Duck", "list", "Eagle", "Earthworm", "Earwig", "Echidna", "Eel", "Egret", "Elephant", "Elk", "Emu", "Ermine", "Falcon", "Ferret", "Finch", "Firefly", "Fish", "Flamingo", "Flea", "Fly", "Flyingfish", "Fowl", "Fox", "Frog", "Gamefowl", "list", "Galliform", "list", "Gazelle", "Gecko", "Gerbil", "Gibbon", "Giraffe", "Goat", "list", "Goldfish", "Goose", "list", "Gopher", "Gorilla", "Grasshopper", "Grouse", "Guan", "list", "Guanaco", "Guineafowl", "list", "list", "Gull", "Guppy", "Haddock", "Halibut", "Hamster", "Hare", "Harrier", "Hawk", "Hedgehog", "Heron", "Herring", "Hippopotamus", "Hookworm", "Hornet", "Horse", "list", "Hoverfly", "Hummingbird", "Hyena", "Iguana", "Impala", "Jackal", "Jaguar", "Jay", "Jellyfish", "Junglefowl", "Kangaroo", "Kingfisher", "Kite", "Kiwi", "Koala", "Koi", "Krill", "Ladybug", "Lamprey", "Landfowl", "Lark", "Leech", "Lemming", "Lemur", "Leopard", "Leopon", "Limpet", "Lion", "Lizard", "Llama", "Lobster", "Locust", "Loon", "Louse", "Lungfish", "Lynx", "Macaw", "Mackerel", "Magpie", "Mammal", "Manatee", "Mandrill", "Marlin", "Marmoset", "Marmot", "Marsupial", "Marten", "Mastodon", "Meadowlark", "Meerkat", "Mink", "Minnow", "Mite", "Mockingbird", "Mole", "Mollusk", "Mongoose", "Monkey", "Moose", "Mosquito", "Moth", "Mouse", "Mule", "Muskox", "Narwhal", "Newt", "Nightingale", "Ocelot", "Octopus", "Opossum", "Orangutan", "Orca", "Ostrich", "Otter", "Owl", "Ox", "Panda", "Panther", "Parakeet", "Parrot", "Parrotfish", "Partridge", "Peacock", "Peafowl", "Pelican", "Penguin", "Perch", "Pheasant", "Pig", "Pigeon", "list", "Pike", "Pinniped", "Piranha", "Planarian", "Platypus", "Pony", "Porcupine", "Porpoise", "Possum", "Prawn", "Primate", "Ptarmigan", "Puffin", "Puma", "Python", "Quail", "Quelea", "Quokka", "Rabbit", "list", "Raccoon", "Rat", "Rattlesnake", "Raven", "Reindeer", "Reptile", "Rhinoceros", "Roadrunner", "Rodent", "Rook", "Rooster", "Roundworm", "Sailfish", "Salamander", "Salmon", "Sawfish", "Scallop", "Scorpion", "Seahorse", "Shark", "list", "Sheep", "list", "Shrew", "Shrimp", "Silkworm", "Silverfish", "Skink", "Skunk", "Sloth", "Slug", "Smelt", "Snail", "Snake", "list", "Snipe", "Sole", "Sparrow", "Spider", "Spoonbill", "Squid", "Squirrel", "Starfish", "Stingray", "Stoat", "Stork", "Sturgeon", "Swallow", "Swan", "Swift", "Swordfish", "Swordtail", "Tahr", "Takin", "Tapir", "Tarantula", "Tarsier", "Termite", "Tern", "Thrush", "Tick", "Tiger", "Tiglon", "Toad", "Tortoise", "Toucan", "Trout", "Tuna", "Turkey", "list", "Turtle", "Tyrannosaurus", "Urial", "Vicuna", "Viper", "Vole", "Vulture", "Wallaby", "Walrus", "Wasp", "Warbler", "Weasel", "Whale", "Whippet", "Whitefish", "Wildcat", "Wildebeest", "Wildfowl", "Wolf", "Wolverine", "Wombat", "Woodpecker", "Worm", "Wren", "Xerinae", "Yak", "Zebra", "Alpaca", "Cat", "Cattle", "Chicken", "Dog", "Donkey", "Ferret", "Gayal", "Goldfish", "Guppy", "Horse", "Koi", "Llama", "Sheep", "Yak"]
  
}
