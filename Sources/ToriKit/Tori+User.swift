//
//  Tori+User.swift
//  
//
//  Created by Ethan Lipnik on 6/24/21.
//

import Foundation
//import Swifter

extension Tori {
    
    public struct UserIdentifer {
        public var id: String?
        public var screenName: String?
        
        public static func screenName(_ screenName: String) -> UserIdentifer {
            return UserIdentifer.init(screenName: screenName)
        }
        public static func id(_ id: String) -> UserIdentifer {
            return UserIdentifer.init(id: id)
        }
        
        public var value: String {
            return id ?? screenName!
        }
    }
    
    public func getUser(_ id: UserIdentifer) async throws -> User {
        let request = try createRequest("show/user")

        let data = try await URLSession.shared.data(for: request).0

        return try JSONDecoder().decode(User.self, from: data)
    }
    
    public func getUserTweets<T>(_ user: T, count: Int = 50, includeRetweets: Bool = true, excludeReplies: Bool = false) async throws -> [Tweet] {
        let request = try createRequest("user_timeline")

        let data = try await URLSession.shared.data(for: request).0

        return try JSONDecoder().decode([Tweet].self, from: data)
    }
    
//    public func getUser(_ id: UserIdentifer, completion: @escaping (Result<User, Error>) -> Void) {
//        swifter?.showUser(id.screenName != nil ? .screenName(id.value) : .id(id.value), includeEntities: true, success: { json in
//            guard let data = "\(json)".data(using: .utf8) else { completion(.failure(URLError(.badServerResponse))); return }
//            
//            do {
//                completion(.success(try JSONDecoder().decode(User.self, from: data)))
//            } catch {
//                completion(.failure(error))
//            }
//        }, failure: { error in
//            completion(.failure(error))
//        })
//    }
//    
//    public func getUserTweets<T>(_ user: T, count: Int = 50, includeRetweets: Bool = true, excludeReplies: Bool = false, completion: @escaping (Result<[Tweet], Error>) -> Void) {
//        guard let userID = (user as? User)?.id ?? user as? String else { return }
//        
//        swifter?.getTimeline(for: .id(userID), count: count, excludeReplies: excludeReplies, includeRetweets: includeRetweets, includeEntities: true, tweetMode: .extended, success: { json in
//            guard let data = "\(json)".data(using: .utf8) else { completion(.failure(URLError(.badServerResponse))); return }
//            
//            do {
//                completion(.success(try JSONDecoder().decode([Tweet].self, from: data)))
//            } catch {
//                completion(.failure(error))
//            }
//        }, failure: { error in
//            completion(.failure(error))
//        })
//    }
}
