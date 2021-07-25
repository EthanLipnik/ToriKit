//
//  Tori+MentionsTimeline.swift
//  
//
//  Created by Ethan Lipnik on 7/5/21.
//

import Foundation
import Combine
//import Swifter

extension Tori {
    public func getMentionsTimeline(count: Int = 200) async throws -> [Tweet] {
        let request = try createRequest("mentions_timeline")

        let data = try await URLSession.shared.data(for: request).0

        return try JSONDecoder().decode([Tweet].self, from: data)
    }
//    public func getMentionsTimeline(count: Int = 200) -> Future<[Tweet], Error> {
//        return Future { promise in
//            self.swifter?.getMentionsTimelineTweets(count: count, includeEntities: true, tweetMode: .extended, success: { json in
//                guard let data = "\(json)".data(using: .utf8) else { promise(.failure(URLError(.badServerResponse))); return }
//                
//                do {
//                    promise(.success(try JSONDecoder().decode([Tweet].self, from: data)))
//                } catch {
//                    promise(.failure(error))
//                }
//            }, failure: { error in
//                promise(.failure(error))
//            })
//        }
//    }
}
