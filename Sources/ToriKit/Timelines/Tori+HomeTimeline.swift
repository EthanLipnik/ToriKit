//
//  Tori+HomeTimeline.swift
//  
//
//  Created by Ethan Lipnik on 6/9/21.
//

import Foundation
import Combine

extension Tori {
    public func getHomeTimeline(tweetMode: TweetMode = .extended, count: Int = 50) async throws -> [Tweet] {
        let request = try createRequest("statuses",
                                        api: "home_timeline",
                                        parameters: [
                                            URLQueryItem(name: "tweet_mode",
                                                         value: tweetMode.rawValue),
                                            URLQueryItem(name: "count",
                                                         value: "\(count)")
                                        ])
        
        let data = try await URLSession.shared.data(for: request).0
        return try JSONDecoder().decode([Tweet].self, from: data)
    }
}
