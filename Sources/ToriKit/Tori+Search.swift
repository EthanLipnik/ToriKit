//
//  Tori+Search.swift
//  
//
//  Created by Ethan Lipnik on 10/7/21.
//

import Foundation

extension Tori {
    public func search(_ query: String) async throws -> [Tweet] {
        return try await withCheckedThrowingContinuation({ continuation in
            swifter?.searchTweet(using: query, count: 200, tweetMode: .extended, success: { json, searchMetadata in
                guard let data = "\(json)".data(using: .utf8) else { continuation.resume(throwing: URLError(.badServerResponse)); return }

                do {
                    let tweets = try JSONDecoder().decode([Tweet].self, from: data)
                        .filter({ $0.retweet == nil })
                    continuation.resume(returning: tweets)
                } catch {
                    continuation.resume(throwing: error)
                }
            }, failure: { error in
                continuation.resume(throwing: error)
            })
        })
    }
    
    public func search(_ query: String) async throws -> [User] {
        return try await withCheckedThrowingContinuation({ continuation in
            swifter?.searchUsers(using: query, count: 200, success: { json in
                guard let data = "\(json)".data(using: .utf8) else { continuation.resume(throwing: URLError(.badServerResponse)); return }

                do {
                    let users = try JSONDecoder().decode([User].self, from: data)
                    continuation.resume(returning: users)
                } catch {
                    continuation.resume(throwing: error)
                }
            }, failure: { error in
                continuation.resume(throwing: error)
            })
        })
    }
}
