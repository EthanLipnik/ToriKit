//
//  Tori+Search.swift
//  
//
//  Created by Ethan Lipnik on 10/7/21.
//

import Foundation

extension Tori {
    
    public func search(_ query: String, count: Int = 50, tweetMode: TweetMode = .extended, sinceID: String? = nil) async throws -> SearchTweetsResults {
        var parameters = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "count", value: "\(count)"),
            URLQueryItem(name: "tweet_mode", value: tweetMode.rawValue),
            URLQueryItem(name: "include_entities", value: "true")
        ]
        
        if let sinceID = sinceID {
            parameters.append(URLQueryItem(name: "since_id", value: sinceID))
        }
        
        let request = try createRequest("search",
                                        api: "tweets",
                                        parameters: parameters)
        
        let data = try await URLSession.shared.data(for: request).0
        print(try JSONSerialization.jsonObject(with: data, options: []))
        return try JSONDecoder().decode(SearchTweetsResults.self, from: data)
    }
    
    public func search(_ query: String, count: Int = 50) async throws -> [User] {
        let request = try createRequest("users",
                                        api: "search",
                                        parameters: [
                                            URLQueryItem(name: "q", value: query),
                                            URLQueryItem(name: "count", value: "\(count)"),
                                            URLQueryItem(name: "include_entities", value: "true")
                                        ])
        
        let data = try await URLSession.shared.data(for: request).0
        return try JSONDecoder().decode([User].self, from: data)
    }
}
