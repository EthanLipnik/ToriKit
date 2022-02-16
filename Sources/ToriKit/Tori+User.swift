//
//  Tori+User.swift
//  
//
//  Created by Ethan Lipnik on 6/24/21.
//

import Foundation

extension Tori {
    public func getUser(_ id: UserIdentifer) async throws -> User {
        var parameters: [URLQueryItem] = [URLQueryItem(name: "include_entities", value: "true")]
        
        switch id {
        case .id(let id):
            parameters.append(URLQueryItem(name: "user_id", value: id))
        case .screenName(let screenName):
            parameters.append(URLQueryItem(name: "screen_name", value: screenName))
        }
        
        let request = try createRequest("users",
                                        api: "show",
                                        parameters: parameters)

        let data = try await URLSession.shared.data(for: request).0
        return try JSONDecoder().decode(User.self, from: data)
    }
    
    public func getUserTweets<T>(_ user: T, count: Int = 50, tweetMode: TweetMode = .extended, includeRetweets: Bool = true, excludeReplies: Bool = false) async throws -> [Tweet] {
        
        var parameters: [URLQueryItem] = [URLQueryItem(name: "count",
                                                       value: "\(count)"),
                                          URLQueryItem(name: "include_rts",
                                                       value: "\(includeRetweets)"),
                                          URLQueryItem(name: "exclude_replies",
                                                       value: "\(excludeReplies)"),
                                          URLQueryItem(name: "tweet_mode",
                                                       value: tweetMode.rawValue)]
        
        if let user = user as? User {
            parameters.append(URLQueryItem(name: "user_id", value: user.id))
        } else if let identifer = user as? UserIdentifer {
            parameters.append(identifer.queryItem())
        }
        
        let request = try createRequest("statuses",
                                        api: "user_timeline",
                                        parameters: parameters)

        let data = try await URLSession.shared.data(for: request).0
        return try JSONDecoder().decode([Tweet].self, from: data)
    }
    
    public func follow<T>(_ user: T) async throws {
        var parameters: [URLQueryItem] = []
        
        if let user = user as? User {
            parameters.append(URLQueryItem(name: "user_id", value: user.id))
        } else if let identifer = user as? UserIdentifer {
            parameters.append(identifer.queryItem())
        }
        
        let request = try createRequest("friendships",
                                        api: "create",
                                        parameters: parameters,
                                        method: .post)
        
        let _ = try await URLSession.shared.data(for: request).0
    }
    
    public func unfollow<T>(_ user: T) async throws {
        var parameters: [URLQueryItem] = []
        
        if let user = user as? User {
            parameters.append(URLQueryItem(name: "user_id", value: user.id))
        } else if let identifer = user as? UserIdentifer {
            parameters.append(identifer.queryItem())
        }
        
        let request = try createRequest("friendships",
                                        api: "destroy",
                                        parameters: parameters,
                                        method: .post)
        
        let _ = try await URLSession.shared.data(for: request).0
    }
}
