//
//  Tori+Post.swift
//  
//
//  Created by Ethan Lipnik on 6/25/21.
//

import Foundation
//import Swifter

extension Tori {
    @discardableResult public func sendTweet(_ text: String) async throws -> Tweet {
        let request = try createRequest("statuses/update")

        let data = try await URLSession.shared.data(for: request).0

        return try JSONDecoder().decode(Tweet.self, from: data)
    }
    
    public func delete<T>(_ tweet: T) {
        
    }
    
    public func like<T>(_ tweet: T) {
        
    }
    
    public func unlike<T>(_ tweet: T) {
        
    }
//    public func sendTweet(_ text: String, completion: ((Result<Tweet, Error>) -> Void)? = nil) {
//        swifter?.postTweet(status: text, tweetMode: .extended, success: { json in
//            guard let data = "\(json)".data(using: .utf8) else { completion?(.failure(URLError(.badServerResponse))); return }
//            
//            do {
//                completion?(.success(try JSONDecoder().decode(Tweet.self, from: data)))
//            } catch {
//                completion?(.failure(error))
//            }
//        }, failure: { error in
//            completion?(.failure(error))
//        })
//    }
//    
//    public func delete<T>(_ tweet: T) {
//        guard let id = (tweet as? Tweet)?.id ?? (tweet as? String) else { return }
//        
//        swifter?.destroyTweet(forID: id)
//    }
//    
//    public func like<T>(_ tweet: T) {
//        guard let id = (tweet as? Tweet)?.id ?? (tweet as? String) else { return }
//        
//        swifter?.favoriteTweet(forID: id)
//    }
//    
//    public func unlike<T>(_ tweet: T) {
//        guard let id = (tweet as? Tweet)?.id ?? (tweet as? String) else { return }
//        
//        swifter?.unfavoriteTweet(forID: id)
//    }
}
