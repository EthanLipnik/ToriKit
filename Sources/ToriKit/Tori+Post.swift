//
//  Tori+Post.swift
//  
//
//  Created by Ethan Lipnik on 6/25/21.
//

import Foundation

extension Tori {
    @discardableResult public func sendTweet(_ text: String, replyID: String? = nil, media: Data? = nil) async throws -> Tweet {
        var parameters: [URLQueryItem] = [URLQueryItem(name: "status", value: text)]
        
        if let replyID = replyID {
            parameters.append(contentsOf: [
                URLQueryItem(name: "in_reply_to_status_id", value: replyID),
                URLQueryItem(name: "auto_populate_reply_metadata", value: "true")
            ])
        }
        
        let request = try createRequest("statuses",
                                        api: "update",
                                        parameters: parameters,
                                        method: .post)

        let data = try await URLSession.shared.data(for: request).0
        return try JSONDecoder().decode(Tweet.self, from: data)
        
//        return try await withCheckedThrowingContinuation({ continuation in
//            let successHandler: Swifter.SuccessHandler = { json in
//                guard let data = "\(json)".data(using: .utf8) else { continuation.resume(throwing: URLError(.badServerResponse)); return }
//
//                do {
//                    let tweets = try JSONDecoder().decode(Tweet.self, from: data)
//                    continuation.resume(returning: tweets)
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            }
//            let failureHandler: Swifter.FailureHandler = { error in
//                continuation.resume(throwing: error)
//            }
//            
//            if let media = media {
//                swifter?.postTweet(status: text, media: media, inReplyToStatusID: replyID, autoPopulateReplyMetadata: replyID != nil, tweetMode: .extended, success: successHandler, failure: failureHandler)
//            } else {
//                swifter?.postTweet(status: text, inReplyToStatusID: replyID, autoPopulateReplyMetadata: replyID != nil, tweetMode: .extended, success: successHandler, failure: failureHandler)
//            }
//        })
    }
    
    public func delete<T>(_ tweet: T) async throws {
        guard let id = (tweet as? Tweet)?.id ?? tweet as? String else { throw URLError(.badURL) }
        
        let request = try createRequest("statuses/destroy",
                                        api: id,
                                        method: .post)

        let _ = try await URLSession.shared.data(for: request).0
    }
    
    public func like<T>(_ tweet: T) async throws {
        guard let id = (tweet as? Tweet)?.id ?? tweet as? String else { throw URLError(.badURL) }
        
        let request = try createRequest("favorites",
                                        api: "create",
                                        parameters: [URLQueryItem(name: "id", value: id)],
                                        method: .post)
        
        let _ = try await URLSession.shared.data(for: request).0
    }
    
    public func unlike<T>(_ tweet: T) async throws {
        guard let id = (tweet as? Tweet)?.id ?? tweet as? String else { throw URLError(.badURL) }
        
        let request = try createRequest("favorites",
                                        api: "destroy",
                                        parameters: [URLQueryItem(name: "id", value: id)],
                                        method: .post)
        
        let _ = try await URLSession.shared.data(for: request).0
    }
    
    public func retweet<T>(_ tweet: T) async throws {
        guard let id = (tweet as? Tweet)?.id ?? tweet as? String else { throw URLError(.badURL) }
        
        let request = try createRequest("statuses/retweet",
                                        api: id,
                                        method: .post)
        
        let _ = try await URLSession.shared.data(for: request).0
    }
    
    public func unretweet<T>(_ tweet: T) async throws {
        guard let id = (tweet as? Tweet)?.id ?? tweet as? String else { throw URLError(.badURL) }
        
        let request = try createRequest("statuses/unretweet",
                                        api: id,
                                        method: .post)
        
        let _ = try await URLSession.shared.data(for: request).0
    }
    
    public func getTweet(_ id: String, tweetMode: TweetMode = .extended) async throws -> Tweet {
        let request = try createRequest("statuses",
                                        api: "show",
                                        parameters: [
                                            URLQueryItem(name: "id",
                                                         value: id),
                                            URLQueryItem(name: "include_entities",
                                                         value: "true"),
                                            URLQueryItem(name: "tweet_mode", value: tweetMode.rawValue)
                                        ])

        let data = try await URLSession.shared.data(for: request).0
        return try JSONDecoder().decode(Tweet.self, from: data)
    }
    
    public func getReplies(_ tweet: Tweet, count: Int = 20, tweetMode: TweetMode = .extended) async throws -> [Tweet] {
        guard let username = tweet.user?.screenName else { throw URLError(.badURL) }
        return try await search("@" + username, count: count, tweetMode: tweetMode, sinceID: tweet.id).statuses
    }
}
