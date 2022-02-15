//
//  Tori+Post.swift
//  
//
//  Created by Ethan Lipnik on 6/25/21.
//

import Foundation
import Swifter

extension Tori {
    @discardableResult public func sendTweet(_ text: String, replyID: String? = nil, media: Data? = nil) async throws -> Tweet {
//        let request = try createRequest("statuses/update")
//
//        let data = try await URLSession.shared.data(for: request).0
//
//        return try JSONDecoder().decode(Tweet.self, from: data)
        
        return try await withCheckedThrowingContinuation({ continuation in
            let successHandler: Swifter.SuccessHandler = { json in
                guard let data = "\(json)".data(using: .utf8) else { continuation.resume(throwing: URLError(.badServerResponse)); return }

                do {
                    let tweets = try JSONDecoder().decode(Tweet.self, from: data)
                    continuation.resume(returning: tweets)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            let failureHandler: Swifter.FailureHandler = { error in
                continuation.resume(throwing: error)
            }
            
            if let media = media {
                swifter?.postTweet(status: text, media: media, inReplyToStatusID: replyID, autoPopulateReplyMetadata: replyID != nil, tweetMode: .extended, success: successHandler, failure: failureHandler)
            } else {
                swifter?.postTweet(status: text, inReplyToStatusID: replyID, autoPopulateReplyMetadata: replyID != nil, tweetMode: .extended, success: successHandler, failure: failureHandler)
            }
        })
    }
    
    public func delete<T>(_ tweet: T) {
        
    }
    
    public func like<T>(_ tweet: T) async throws {
        guard let id = (tweet as? Tweet)?.id ?? tweet as? String else { throw URLError(.badURL) }
        
        return try await withCheckedThrowingContinuation({ continuation in
            swifter?.favoriteTweet(forID: id, success: { _ in
                continuation.resume()
            }, failure: { error in
                continuation.resume(throwing: error)
            })
        })
    }
    
    public func unlike<T>(_ tweet: T) async throws {
        guard let id = (tweet as? Tweet)?.id ?? tweet as? String else { throw URLError(.badURL) }
        
        return try await withCheckedThrowingContinuation({ continuation in
            swifter?.unfavoriteTweet(forID: id, success: { _ in
                continuation.resume()
            }, failure: { error in
                continuation.resume(throwing: error)
            })
        })
    }
    
    public func retweet<T>(_ tweet: T) async throws {
        guard let id = (tweet as? Tweet)?.id ?? tweet as? String else { throw URLError(.badURL) }
        
        return try await withCheckedThrowingContinuation({ continuation in
            swifter?.retweetTweet(forID: id, success: { _ in
                continuation.resume()
            }, failure: { error in
                continuation.resume(throwing: error)
            })
        })
    }
    
    public func unretweet<T>(_ tweet: T) async throws {
        guard let id = (tweet as? Tweet)?.id ?? tweet as? String else { throw URLError(.badURL) }
        
        return try await withCheckedThrowingContinuation({ continuation in
            swifter?.unretweetTweet(forID: id, success: { _ in
                continuation.resume()
            }, failure: { error in
                continuation.resume(throwing: error)
            })
        })
    }
    
    public func getTweet(_ id: String) async throws -> Tweet {
        return try await withCheckedThrowingContinuation({ continuation in
            swifter?.getTweet(for: id, includeEntities: true, tweetMode: .extended, success: { json in
                guard let data = "\(json)".data(using: .utf8) else { continuation.resume(throwing: URLError(.badServerResponse)); return }

                do {
                    let tweets = try JSONDecoder().decode(Tweet.self, from: data)
                    continuation.resume(returning: tweets)
                } catch {
                    continuation.resume(throwing: error)
                }
            }, failure: { error in
                continuation.resume(throwing: error)
            })
        })
    }
    
    public func sendTweet(_ text: String, completion: ((Result<Tweet, Error>) -> Void)? = nil) {
        swifter?.postTweet(status: text, tweetMode: .extended, success: { json in
            guard let data = "\(json)".data(using: .utf8) else { completion?(.failure(URLError(.badServerResponse))); return }
            
            do {
                completion?(.success(try JSONDecoder().decode(Tweet.self, from: data)))
            } catch {
                completion?(.failure(error))
            }
        }, failure: { error in
            completion?(.failure(error))
        })
    }
    
    public func getReplies(_ tweet: Tweet) async throws -> [Tweet] {
        return try await withCheckedThrowingContinuation({ continuation in
            swifter?.searchTweet(using: "@" + tweet.user!.username, count: 20, sinceID: tweet.id, tweetMode: .extended, success: { json, response in
                guard let data = "\(json)".data(using: .utf8) else { continuation.resume(throwing: URLError(.badServerResponse)); return }

                do {
                    let tweets = try JSONDecoder().decode([Tweet].self, from: data)
                        .map({ $0.retweet ?? $0 })
                        .filter({ $0.replyID == tweet.id })
                    continuation.resume(returning: tweets)
                } catch {
                    continuation.resume(throwing: error)
                }
            }, failure: { error in
                continuation.resume(throwing: error)
            })
        })
    }
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
