//
//  DataStore+Matches.swift
//  Pear
//
//  Created by Avery Lamp on 6/19/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

// MARK: - Data Store Matches Extensions
extension DataStore {
  
  /// Refreshes the current matches that the current user has received
  ///
  /// - Parameter matchRequestsFound: Runs a completion when the matches have completed fetching
  func refreshCurrentMatches(matchRequestsFound: (([Match]) -> Void)?) {
    self.fetchUIDToken { (result) in
      switch result {
      case .success(let authTokens):
        PearMatchesAPI.shared.getMatchesForUser(uid: authTokens.uid,
                                                token: authTokens.token,
                                                matchType: .currentMatches,
                                                completion: { (result) in
                                                  switch result {
                                                  case .success(let matches):
                                                    self.currentMatches = matches
                                                    print("Current Matches:\(self.matchRequests.count)")
                                                    NotificationCenter.default.post(name: .refreshChatsTab, object: nil)
                                                    if let matchCompletion = matchRequestsFound {
                                                      matchCompletion(matches)
                                                    }
                                                  case .failure(let error):
                                                    print("Failure getting error: \(error)")
                                                    if let matchCompletion = matchRequestsFound {
                                                      matchCompletion([])
                                                    }
                                                  }
        })
      case .failure(let error):
        print("Failure getting Tokens: \(error)")
        if let matchCompletion = matchRequestsFound {
          matchCompletion([])
        }
        return
      }
    }
  }
  
  /// Refreshes the match requests a user has received
  ///
  /// - Parameter matchRequestsFound: optional completion for after a refresh occurs
  func refreshMatchRequests(matchRequestsFound: (([Match]) -> Void)?) {
    self.fetchUIDToken { (result) in
      switch result {
      case .success(let authTokens):
        PearMatchesAPI.shared.getMatchesForUser(uid: authTokens.uid,
                                                token: authTokens.token,
                                                matchType: .matchRequests,
                                                completion: { (result) in
                                                  switch result {
                                                  case .success(let matches):
                                                    do {
                                                      let encodedMatches = try JSONEncoder().encode(matches)
                                                      UserDefaults.standard.set(encodedMatches, forKey: UserDefaultKeys.cachedMatches.rawValue)
                                                    } catch {
                                                      print("Error: \(error)")
                                                    }

                                                    self.matchRequests = matches
                                                    print("Match Requests:\(self.matchRequests.count)")
                                                    NotificationCenter.default.post(name: .refreshChatsTab, object: nil)
                                                    if let matchCompletion = matchRequestsFound {
                                                      matchCompletion(matches)
                                                    }
                                                  case .failure(let error):
                                                    print("Failure getting error: \(error)")
                                                    if let matchCompletion = matchRequestsFound {
                                                      matchCompletion([])
                                                    }
                                                  }
        })
      case .failure(let error):
        print("Failure getting Tokens: \(error)")
        if let matchCompletion = matchRequestsFound {
          matchCompletion([])
        }
        return
      }
    }
  }

}
