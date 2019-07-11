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
    if let user = DataStore.shared.currentPearUser {
      self.userEvents.append(SlackEvent(text: user.toSlackStorySummary(profileStats: true, currentUserStats: true),
                                        color: UIColor.green.hexColor))
    }
  }
  
  func addEvent(uniquePrefix: String, text: String, color: UIColor) {
    if !self.userEvents.contains(where: { $0.text.contains(uniquePrefix)}) {
      self.userEvents.append(SlackEvent(text: "\(uniquePrefix) \(text)", color: color.hexColor))
    }
  }
  
  func addEvent(text: String, color: UIColor = UIColor.black) {
    #if DEVMODE
    print(text)
    #endif
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
      if self.userEvents.count > 0 {
        self.userEvents.insert(SlackEvent(text: "End Session: " + user.toSlackStorySummary(profileStats: true, currentUserStats: true),
                                          color: UIColor.green.hexColor), at: 1)
      } else {
        self.userEvents.append(SlackEvent(text: user.toSlackStorySummary(profileStats: true, currentUserStats: true),
                                          color: UIColor.green.hexColor))
      }
    }
    self.userEvents.insert(SlackEvent(text: "_______________________________________\nSession Duration: \(Int(timePassed))s, Session Number: \(sessionNumber), Events: \(self.userEvents.count) \(lastSessionString != nil ? "\n\(lastSessionString!)" : "")", color: UIColor.purple.hexColor), at: 0)
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
  static let animalNames: [String] = ["Canidae", "Felidae", "Cat", "Cattle", "Dog", "Donkey", "Goat", "Horse", "Pig", "Rabbit", "Aardvark", "Aardwolf", "Albatross", "Alligator", "Alpaca", "Amphibian", "list", "Anaconda", "Angelfish", "Anglerfish", "Ant", "Anteater", "Antelope", "Antlion", "Ape", "Aphid", "Armadillo", "Asp", "Baboon", "Badger", "Bandicoot", "Barnacle", "Barracuda", "Basilisk", "Bass", "Bat", "Bear", "list", "Beaver", "Bedbug", "Bee", "Beetle", "Bird", "list", "Bison", "Blackbird", "Boa", "Boar", "Bobcat", "Bobolink", "Bonobo", "Booby", "Bovid", "Bug", "Butterfly", "Buzzard", "Camel", "Canid", "Capybara", "Cardinal", "Caribou", "Carp", "Cat", "list", "Catshark", "Caterpillar", "Catfish", "Cattle", "list", "Centipede", "Cephalopod", "Chameleon", "Cheetah", "Chickadee", "Chicken", "list", "Chimpanzee", "Chinchilla", "Chipmunk", "Clam", "Clownfish", "Cobra", "Cockroach", "Cod", "Condor", "Constrictor", "Coral", "Cougar", "Cow", "Coyote", "Crab", "Crane", "Crawdad", "Crayfish", "Cricket", "Crocodile", "Crow", "Cuckoo", "Cicada", "Damselfly", "Deer", "Dingo", "Dinosaur", "list", "Dog", "list", "Dolphin", "Donkey", "list", "Dormouse", "Dove", "Dragonfly", "Dragon", "Duck", "list", "Eagle", "Earthworm", "Earwig", "Echidna", "Eel", "Egret", "Elephant", "Elk", "Emu", "Ermine", "Falcon", "Ferret", "Finch", "Firefly", "Fish", "Flamingo", "Flea", "Fly", "Flyingfish", "Fowl", "Fox", "Frog", "Gamefowl", "list", "Galliform", "list", "Gazelle", "Gecko", "Gerbil", "Gibbon", "Giraffe", "Goat", "list", "Goldfish", "Goose", "list", "Gopher", "Gorilla", "Grasshopper", "Grouse", "Guan", "list", "Guanaco", "Guineafowl", "list", "list", "Gull", "Guppy", "Haddock", "Halibut", "Hamster", "Hare", "Harrier", "Hawk", "Hedgehog", "Heron", "Herring", "Hippopotamus", "Hookworm", "Hornet", "Horse", "list", "Hoverfly", "Hummingbird", "Hyena", "Iguana", "Impala", "Jackal", "Jaguar", "Jay", "Jellyfish", "Junglefowl", "Kangaroo", "Kingfisher", "Kite", "Kiwi", "Koala", "Koi", "Krill", "Ladybug", "Lamprey", "Landfowl", "Lark", "Leech", "Lemming", "Lemur", "Leopard", "Leopon", "Limpet", "Lion", "Lizard", "Llama", "Lobster", "Locust", "Loon", "Louse", "Lungfish", "Lynx", "Macaw", "Mackerel", "Magpie", "Mammal", "Manatee", "Mandrill", "Marlin", "Marmoset", "Marmot", "Marsupial", "Marten", "Mastodon", "Meadowlark", "Meerkat", "Mink", "Minnow", "Mite", "Mockingbird", "Mole", "Mollusk", "Mongoose", "Monkey", "Moose", "Mosquito", "Moth", "Mouse", "Mule", "Muskox", "Narwhal", "Newt", "Nightingale", "Ocelot", "Octopus", "Opossum", "Orangutan", "Orca", "Ostrich", "Otter", "Owl", "Ox", "Panda", "Panther", "Parakeet", "Parrot", "Parrotfish", "Partridge", "Peacock", "Peafowl", "Pelican", "Penguin", "Perch", "Pheasant", "Pig", "Pigeon", "list", "Pike", "Pinniped", "Piranha", "Planarian", "Platypus", "Pony", "Porcupine", "Porpoise", "Possum", "Prawn", "Primate", "Ptarmigan", "Puffin", "Puma", "Python", "Quail", "Quelea", "Quokka", "Rabbit", "list", "Raccoon", "Rat", "Rattlesnake", "Raven", "Reindeer", "Reptile", "Rhinoceros", "Roadrunner", "Rodent", "Rook", "Rooster", "Roundworm", "Sailfish", "Salamander", "Salmon", "Sawfish", "Scallop", "Scorpion", "Seahorse", "Shark", "list", "Sheep", "list", "Shrew", "Shrimp", "Silkworm", "Silverfish", "Skink", "Skunk", "Sloth", "Slug", "Smelt", "Snail", "Snake", "list", "Snipe", "Sole", "Sparrow", "Spider", "Spoonbill", "Squid", "Squirrel", "Starfish", "Stingray", "Stoat", "Stork", "Sturgeon", "Swallow", "Swan", "Swift", "Swordfish", "Swordtail", "Tahr", "Takin", "Tapir", "Tarantula", "Tarsier", "Termite", "Tern", "Thrush", "Tick", "Tiger", "Tiglon", "Toad", "Tortoise", "Toucan", "Trout", "Tuna", "Turkey", "list", "Turtle", "Tyrannosaurus", "Urial", "Vicuna", "Viper", "Vole", "Vulture", "Wallaby", "Walrus", "Wasp", "Warbler", "Weasel", "Whale", "Whippet", "Whitefish", "Wildcat", "Wildebeest", "Wildfowl", "Wolf", "Wolverine", "Wombat", "Woodpecker", "Worm", "Wren", "Xerinae", "Yak", "Zebra", "Alpaca", "Cat", "Cattle", "Chicken", "Dog", "Donkey", "Ferret", "Gayal", "Goldfish", "Guppy", "Horse", "Koi", "Llama", "Sheep", "Yak"]
  // swiftlint:disable:next line_length
  static let colors: [String] = ["Sunny", "Kobi", "Scarlet", "Zest", "Zomp", "Flamingo", "Frangipani", "Cinderella", "Niagara", "Haiti", "Rebel", "Spice", "Gin", "Jambalaya", "Armadillo", "Sorbus", "Wheatfield", "Nyanza", "Charade", "Amaranth", "Victoria", "Gossip", "Perfume", "Lavender", "Mandalay", "Strikemaster", "Bisque", "Cedar", "Mojo", "Raspberry", "Crusoe", "Nevada", "Paradiso", "Licorice", "Fandango", "Tabasco", "Chambray", "Mako", "Mortar", "Magenta", "Gothic", "Opal", "Aztec", "Gondola", "Fuchsia", "Trinidad", "Ruber", "Orinoco", "Prelude", "Wheat", "Holly", "Cognac", "Gamboge", "Byzantine", "Blueberry", "Dallas", "Laurel", "Ottoman", "Matisse", "Pompadour", "Independence", "Tamarind", "Parchment", "Smoky", "Peanut", "Bush", "Alpine", "Bracken", "Mustard", "Jade", "Ebb", "Chablis", "Quincy", "Monsoon", "Atoll", "Axolotl", "Padua", "Nickel", "Castro", "Scarlett", "Lumber", "Sirocco", "Lynch", "Dawn", "Quicksand", "Equator", "Hampton", "Sambuca", "Tiber", "Christalle", "Kelp", "Aubergine", "Emerald", "Tradewind", "Byzantium", "Salem", "Magnolia", "Windsor", "Tulip", "Eclipse", "Biscay", "Cameo", "Bombay", "Camelot", "Sahara", "Bunker", "Galliano", "Madang", "Contessa", "Kangaroo", "Eagle", "Swirl", "Pewter", "Rainee", "Plum", "Lilac", "Gray", "Ronchi", "Cornsilk", "Edgewater", "Goblin", "Cherokee", "Gumbo", "Malta", "Deco", "Blond", "Eternity", "Xanadu", "Sandrift", "Icterine", "Delta", "Grandis", "Quartz", "Mobster", "Bluebonnet", "Rangitoto", "Dogs", "Valhalla", "Sulu", "Kidnapper", "Wasabi", "Woodland", "Bouquet", "Cola", "Ube", "Gorse", "Temptress", "Rajah", "Thatch", "Siren", "Abbey", "Copper", "Juniper", "Sunshade", "Tangaroa", "Romantic", "Swamp", "Geraldine", "Tusk", "Valentino", "Sapphire", "Moccasin", "Millbrook", "Killarney", "Desert", "Isabelline", "Scorpion", "Cerulean", "Laser", "Tangelo", "Matrix", "Bamboo", "Cement", "Beeswax", "Tranquil", "Shampoo", "Mahogany", "Amazon", "Brown", "Teal", "Edward", "Champagne", "Viridian", "Illusion", "Tangerine", "Dorado", "Primrose", "Acadia", "Spindle", "Drover", "Horses", "Blumine", "Sunray", "Russett", "Zorba", "Candlelight", "Jacaranda", "Harlequin", "Dew", "Rust", "Seaweed", "Cyan", "Emperor", "Tallow", "Pampas", "Husk", "Oasis", "Cactus", "Carmine", "Bossanova", "Clairvoyant", "Zumthor", "Marigold", "Bud", "Burgundy", "Arapawa", "Endeavour", "Snow", "Heather", "Honeydew", "Mongoose", "Gravel", "Purple", "Woodsmoke", "Elm", "Parsley", "Bronco", "Picasso", "Bitter", "Pueblo", "Mocha", "Rum", "Marshland", "Charcoal", "Mystic", "Sinbad", "Jacarta", "Creole", "Nutmeg", "Crail", "Jagger", "Kokoda", "Astra", "Treehouse", "Blue", "Onion", "Whiskey", "Frostbite", "Crimson", "Dixie", "Turmeric", "Tuscany", "Diamond", "Cupid", "Zinnwaldite", "Falcon", "Derby", "Blackberry", "Tapa", "Loblolly", "Downy", "Stormcloud", "Lola", "Vermilion", "Indigo", "Sienna", "William", "Cyprus", "Wafer", "Jon", "Tango", "Green", "Cadillac", "Imperial", "Sangria", "Russet", "Mindaro", "Ziggurat", "Blossom", "Malachite", "Monza", "Mosque", "Sunset", "Apache", "Shilo", "Crowshead", "Pipi", "Auburn", "Aluminium", "Oracle", "Bunting", "Gurkha", "Varden", "Denim", "Deer", "Cosmic", "Ecstasy", "Lemon", "Ultramarine", "Keppel", "Pear", "Twilight", "Negroni", "Confetti", "Fern", "Gunmetal", "Fiord", "Rope", "Cadet", "Yellow", "Mabel", "Hurricane", "Hillary", "Conifer", "Surf", "Amber", "Valencia", "Akaroa", "Porcelain", "Roti", "Coral", "Ash", "Tan", "Dirt", "Cloud", "Lucky", "Taupe", "Flirt", "Raffia", "Spectra", "Ao", "Melanzane", "Grizzly", "Finn", "Cardinal", "Starship", "Shadow", "Oxley", "Vesuvius", "Polar", "Iceberg", "Givry", "Sushi", "Finlandia", "Aureolin", "Geyser", "Mantis", "Trout", "Concord", "Sprout", "Brass", "Revolver", "Martini", "Stonewall", "Studio", "Navy", "Sinopia", "Driftwood", "Disco", "Moccaccino", "Ironstone", "Corvette", "Merlot", "Goldenrod", "Sandstone", "Shalimar", "Bizarre", "Jaffa", "Capri", "Clover", "White", "Punga", "Festival", "Schist", "Schooner", "Golden", "Cowboy", "Fulvous", "Limerick", "Chalky", "Shiraz", "Carnelian", "Pearl", "Ivory", "Jet", "Bittersweet", "Rhythm", "Olivine", "Mantle", "Viking", "Kilamanjaro", "Charm", "Seance", "Espresso", "Sapling", "Merino", "Melon", "Sunglo", "Toledo", "Lust", "Puce", "Nandor", "Mamba", "Rosewood", "Anakiwa", "Ghost", "Vanilla", "Putty", "Smoke", "Nobel", "Tumbleweed", "Pacifika", "Eden", "Saratoga", "Java", "Kimberly", "Mondo", "Crusta", "Sandwisp", "Masala", "Cloudy", "Cyclamen", "Cumulus", "Blackcurrant", "Meteorite", "Cruise", "Saffron", "Dolly", "Wine", "Caper", "Boulder", "Purpureus", "Firefly", "Pomegranate", "Ming", "Paua", "Manhattan", "Mischka", "Buccaneer", "Onyx", "Voodoo", "Highland", "Stromboli", "Hacienda", "Manz", "Nero", "Zircon", "Ceramic", "Malibu", "Fallow", "Soap", "Smalt", "Flame", "Coconut", "Carnation", "Mauvelous", "Empress", "Cherrywood", "Fantasy", "Iris", "Orange", "Fog", "Arrowtown", "Feta", "Folly", "Woodrush", "Pippin", "Pumice", "Cordovan", "Aero", "Americano", "Tiara", "Broom", "Tamarillo", "Tuatara", "Corduroy", "Redwood", "Makara", "Hemp", "Sunglow", "Fedora", "Casper", "Shakespeare", "Kobicha", "Timberwolf", "Frost", "Froly", "Turbo", "Harp", "Geebung", "Sail", "Domino", "Iron", "Tussock", "Envy", "Tequila", "Sage", "Charlotte", "Elephant", "Allports", "Liver", "Chiffon", "Buttermilk", "Celtic", "Barossa", "Bahia", "Scandal", "Olive", "Strawberry", "Wedgewood", "Smitten", "Apricot", "Tenne", "Jonquil", "Sycamore", "Cosmos", "Bronze", "Loulou", "Deluge", "Seashell", "Pelorous", "Dandelion", "Chenin", "Cello", "Stiletto", "Concrete", "Bandicoot", "Matterhorn", "Tidal", "Waiouru", "Foam", "Cinereous", "Amulet", "Tea", "Hopbush", "Madras", "Shamrock", "Nepal", "Celery", "Organ", "Fawn", "Firebrick", "Clementine", "Tosca", "Cararra", "Persimmon", "Kumera", "Coffee", "Yuma", "Downriver", "Mallard", "Hemlock", "Christine", "Walnut", "Remy", "Cashmere", "Calico", "Nugget", "Daintree", "Peppermint", "Toast", "Carissma", "Japonica", "Chamoisee", "Citron", "Birch", "Bourbon", "Paprika", "Bermuda", "Pistachio", "Olivetone", "Pizza", "Viola", "Salmon", "Buttercup", "Ebony", "Heliotrope", "Monarch", "Jewel", "Wisteria", "Mikado", "Indochine", "Pancho", "Cerise", "Raven", "Hibiscus", "Opium", "Scampi", "Pharlap", "Alabaster", "Seagull", "Mirage", "Lochinvar", "Peru", "Merlin", "Amethyst", "Artichoke", "Bordeaux", "Observatory", "Grenadier", "Mandarin", "Danube", "Zambezi", "Feijoa", "Whisper", "Nomad", "Zanah", "Tana", "Cinnabar", "Lonestar", "Gallery", "Martinique", "Lipstick", "Watusi", "Casablanca", "Caramel", "Stack", "Sun", "Sisal", "Patina", "Loafer", "Bilbao", "Submarine", "Grullo", "Beaver", "Topaz", "Avocado", "Portage", "Zaffre", "Horizon", "Bistre", "Inchworm", "Cioccolato", "Hoki", "Porsche", "Supernova", "Orient", "Shocking", "Tolopea", "Mandy", "Madison", "Neptune", "Reef", "Wenge", "Honeysuckle", "Red", "Tuna", "Sandstorm", "Cream", "Celeste", "Lima", "Glacier", "Tundora", "Chardon", "Beige", "Koromiko", "Everglade", "Belgion", "Tasman", "Chardonnay", "Bubbles", "Piper", "California", "Burlywood", "Acapulco", "Thunderbird", "Bismark", "Chartreuse", "Oil", "Sundown", "Ecru", "Selago", "Bianca", "Sauvignon", "Marzipan", "Irresistible", "Sandal", "Heath", "Norway", "Muesli", "Como", "Graphite", "Aquamarine", "Wattle", "Teak", "Dolphin", "Pohutukawa", "Napa", "Zeus", "Mimosa", "Peach", "Maverick", "Anzac", "Solitude", "Sidecar", "Gossamer", "Black", "Himalaya", "Tomato", "Boysenberry", "Sunflower", "Lenurple", "Feldgrau", "Lochmara", "Texas", "Sepia", "Vulcan", "Chamois", "Maize", "Wistful", "Dell", "Scooter", "Daffodil", "Coquelicot", "Nebula", "Flavescent", "Janna", "Watercourse", "Affair", "Bridesmaid", "Bastille", "Venus", "Camouflage", "Kabul", "Narvik", "Eunry", "Rufous", "Pizazz", "Ruby", "Gainsboro", "Tara", "Ruddy", "Twine", "Asparagus", "Soapstone", "Panache", "Jasper", "Violet", "Punch", "Linen", "Crete", "Catawba", "Platinum", "Finch", "Popstar", "Karry", "Eggshell", "Azure", "Razzmatazz", "Buff", "Chocolate", "Chestnut", "Skobeloff", "Onahau", "Dingley", "Carla", "Citrine", "Azalea", "Mercury", "Shark", "Melanie", "Lava", "Regalia", "Tapestry", "Sundance", "Plantation", "Paarl", "Jasmine", "Iroko", "Thistle", "Mauve", "Salomie", "Siam", "Pablo", "Portafino", "Lily", "Dune", "Milan", "Minsk", "Ginger", "Melrose", "Manatee", "Fuego", "Frostee", "Stratos", "Riptide", "Chinook", "Atlantis", "Tarawera", "Glitter", "Perano", "Eminence", "Coriander", "Spray", "Flamenco", "Grape", "Clinker", "Prim", "Chantilly", "Zuccini", "Turquoise", "Umber", "Astral", "Conch", "Mariner", "Jumbo", "Khaki", "Asphalt", "Casal", "Roman", "Ceil", "Chatelle", "Silver", "Squirrel", "Periwinkle", "Meteor", "Pink", "Wewak", "Solitaire", "Thunder", "Orchid", "Lotus", "Cherub", "Blush", "Cumin", "Oregon", "Limeade", "Claret", "Rouge", "Astronaut", "Calypso", "Veronica", "Tacha", "Burnham", "Corn", "Silk", "Zombie", "Volt", "Diesel", "Mint", "Karaka", "Verdigris", "Cranberry", "Westar", "Midnight", "Toolbox", "Gimblet", "Apple", "Fire", "Bole", "Glaucous", "Alto", "Amour", "Mulberry", "Eucalyptus", "Brandy", "Arsenic", "Skeptic", "Gunsmoke", "Cork", "Sazerac", "Christi", "Travertine", "Maroon", "Pavlova", "Cinder", "Eggplant", "Citrus", "Waterspout", "Comet", "Snuff", "Serenade", "Paco", "Canary", "Rhino", "Urobilin", "Celadon", "Flint", "Jaguar", "Flax", "Korma", "Straw", "Tutu", "Leather", "Gigas", "Portica", "Peridot", "Bazaar", "Cabaret", "Rock", "Lime", "Ferra", "Pesto", "Almond", "Saltpan", "Bone", "Liberty", "Tacao", "Logan", "Cascade", "Rose", "Camarone", "Ochre", "Saddle", "Telemagenta", "Genoa", "Botticelli", "Desire", "Tide", "Chicago", "Romance", "Pumpkin", "Chino", "Crocodile", "Locust", "Peat", "Bronzetone", "Barberry", "Kournikova"]
  
}
