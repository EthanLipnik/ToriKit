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
//        let request = try createRequest("mentions_timeline")
//
//        let data = try await URLSession.shared.data(for: request).0
//
//        return try JSONDecoder().decode([Tweet].self, from: data)
        
        return try await withCheckedThrowingContinuation({ continuation in
            swifter?.getMentionsTimelineTweets(count: 50, includeEntities: true, tweetMode: .extended, success: { json in
                guard let data = "\(json)".data(using: .utf8) else { continuation.resume(throwing: URLError(.badServerResponse)); return }

                do {
                    let tweets = try JSONDecoder().decode([Tweet].self, from: data)
                    continuation.resume(returning: tweets)
                } catch {
                    continuation.resume(throwing: error)
                }
            }, failure: { error in
                continuation.resume(throwing: error)
            })
        })
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
