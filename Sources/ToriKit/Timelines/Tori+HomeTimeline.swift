//
//  Tori+HomeTimeline.swift
//  
//
//  Created by Ethan Lipnik on 6/9/21.
//

import Foundation
import Combine
import Swifter

extension Tori {
//    public func getHomeTimeline(count: Int = 200) -> Future<[Tweet], Error> {
//        return Future { promise in
//            self.swifter?.getHomeTimeline(count: count, includeEntities: true, tweetMode: .extended, success: { json in
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
    public func getHomeTimeline() async throws -> [Tweet] {
        let request = try createRequest("home_timeline", parameters: [URLQueryItem(name: "tweet_mode", value: "extended")])

        let data = try await URLSession.shared.data(for: request).0

        return try JSONDecoder().decode([Tweet].self, from: data)
    }
    
    public func getHomeTimeline(completion: @escaping (Result<[Tweet], Error>) -> Void) {
        swifter?.getHomeTimeline(count: 200, includeEntities: true, tweetMode: .extended, success: { json in
            guard let data = "\(json)".data(using: .utf8) else { completion(.failure(URLError(.badServerResponse))); return }

            do {
                let tweets = try JSONDecoder().decode([Tweet].self, from: data)
                completion(.success(tweets))
            } catch {
                completion(.failure(error))
            }
        }, failure: { error in
            completion(.failure(error))
        })
    }
}
