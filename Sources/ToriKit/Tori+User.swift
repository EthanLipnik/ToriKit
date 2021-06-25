//
//  Tori+User.swift
//  
//
//  Created by Ethan Lipnik on 6/24/21.
//

import Foundation
import Swifter

extension Tori {
    public func getUser(_ id: String, completion: @escaping (Result<User, Error>) -> Void) {
        swifter?.showUser(.id(id), includeEntities: true, success: { json in
            guard let data = "\(json)".data(using: .utf8) else { completion(.failure(URLError(.badServerResponse))); return }
            
            do {
                completion(.success(try JSONDecoder().decode(User.self, from: data)))
            } catch {
                completion(.failure(error))
            }
        }, failure: { error in
            completion(.failure(error))
        })
    }
    
    public func getUserTweets<T>(_ user: T, count: Int = 50, includeRetweets: Bool = true, excludeReplies: Bool = false, completion: @escaping (Result<[Tweet], Error>) -> Void) {
        guard let userID = (user as? User)?.id ?? user as? String else { return }
        
        swifter?.getTimeline(for: .id(userID), count: count, excludeReplies: excludeReplies, includeRetweets: includeRetweets, includeEntities: true, tweetMode: .extended, success: { json in
            guard let data = "\(json)".data(using: .utf8) else { completion(.failure(URLError(.badServerResponse))); return }
            
            do {
                completion(.success(try JSONDecoder().decode([Tweet].self, from: data)))
            } catch {
                completion(.failure(error))
            }
        }, failure: { error in
            completion(.failure(error))
        })
    }
}
