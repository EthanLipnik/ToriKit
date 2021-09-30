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
        
        return try await withCheckedThrowingContinuation({ continuation in
            swifter?.getHomeTimeline(count: 200, includeEntities: true, tweetMode: .extended, success: { json in
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
//        let request = try createRequest("home_timeline")
//
//        let data = try await URLSession.shared.data(for: request).0
//
//        print(try? JSONSerialization.jsonObject(with: data, options: []))
//        return try JSONDecoder().decode([Tweet].self, from: data)
    }
}
