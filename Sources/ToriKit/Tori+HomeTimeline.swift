//
//  File.swift
//  
//
//  Created by Ethan Lipnik on 6/9/21.
//

import Foundation
import Combine
import Swifter

extension Tori {
    public func getHomeTimeline(count: Int = 200) -> Future<[Tweet], Error> {
        return Future { promise in
            self.swifter?.getHomeTimeline(count: count, includeEntities: true, tweetMode: .extended, success: { json in
                guard let data = "\(json)".data(using: .utf8) else { promise(.failure(URLError(.badServerResponse))); return }
                
                do {
                    promise(.success(try JSONDecoder().decode([Tweet].self, from: data)))
                } catch {
                    promise(.failure(error))
                }
            }, failure: { error in
                promise(.failure(error))
            })
        }
    }
//    public func getHomeTimeline() async throws -> [Tweet] {
//        let request = (baseURLString: "https://api.twitter.com/1.1/statuses/home_timeline.json",
//                       httpMethod: "GET",
//                       consumerKey: credentials.consumerKey,
//                       consumerSecret: credentials.consumerSecret)
//
//        guard let baseURL = URL(string: request.baseURLString) else {
//            throw OAuthError.urlError(URLError(.badURL))
//        }
//
//        guard let accessToken = tokenCredentials?.accessToken, let accessTokenSecret = tokenCredentials?.accessTokenSecret else {
//            throw OAuthError.urlError(URLError(.userAuthenticationRequired))
//        }
//
//        var parameters = [
//            URLQueryItem(name: "oauth_token", value: accessToken),
//            URLQueryItem(name: "oauth_consumer_key", value: request.consumerKey),
//            URLQueryItem(name: "oauth_nonce", value: UUID().uuidString),
//            URLQueryItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
//            URLQueryItem(name: "oauth_timestamp", value: String(Int(Date().timeIntervalSince1970))),
//            URLQueryItem(name: "oauth_version", value: "1.0")
//        ]
//
//        let signature = oAuthSignature(httpMethod: request.httpMethod,
//                                       baseURLString: request.baseURLString,
//                                       parameters: parameters,
//                                       consumerSecret: request.consumerSecret,
//                                       oAuthTokenSecret: accessTokenSecret)
//
//        parameters.append(URLQueryItem(name: "oauth_signature", value: signature))
//        print(signature)
//
//        var urlRequest = URLRequest(url: baseURL)
//        urlRequest.httpMethod = request.httpMethod
//        urlRequest.setValue(oAuthAuthorizationHeader(parameters: parameters),
//                            forHTTPHeaderField: "Authorization")
//
//        let data = try await URLSession.shared.data(for: urlRequest).0
//
////        print(try? JSONSerialization.jsonObject(with: data, options: []))
//        return try JSONDecoder().decode([Tweet].self, from: data)
//    }
}
