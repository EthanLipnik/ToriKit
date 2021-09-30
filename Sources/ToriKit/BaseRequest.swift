//
//  BaseRequest.swift
//  BaseRequest
//
//  Created by Ethan Lipnik on 7/24/21.
//

import Foundation

extension Tori {
    func createRequest(_ api: String) throws -> URLRequest {
        let request = (baseURLString: "https://api.twitter.com/1.1/statuses/\(api).json",
                       httpMethod: "GET",
                       consumerKey: credentials!.consumerKey,
                       consumerSecret: credentials!.consumerSecret)
        
        guard let baseURL = URL(string: request.baseURLString) else {
            throw OAuthError.urlError(URLError(.badURL))
        }
        
        guard let accessToken = tokenCredentials?.accessToken, let accessTokenSecret = tokenCredentials?.accessTokenSecret else {
            throw OAuthError.urlError(URLError(.userAuthenticationRequired))
        }
        
        var parameters = [
            URLQueryItem(name: "oauth_token", value: accessToken),
            URLQueryItem(name: "oauth_consumer_key", value: request.consumerKey),
            URLQueryItem(name: "oauth_nonce", value: UUID().uuidString),
            URLQueryItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
            URLQueryItem(name: "oauth_timestamp", value: String(Int(Date().timeIntervalSince1970))),
            URLQueryItem(name: "oauth_version", value: "1.0")
        ]
        
        let signature = oAuthSignature(httpMethod: request.httpMethod,
                                       baseURLString: request.baseURLString,
                                       parameters: parameters,
                                       consumerSecret: request.consumerSecret,
                                       oAuthTokenSecret: accessTokenSecret)
        
        parameters.append(URLQueryItem(name: "oauth_signature", value: signature))
        
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = request.httpMethod
        urlRequest.setValue(oAuthAuthorizationHeader(parameters: parameters),
                            forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
}
