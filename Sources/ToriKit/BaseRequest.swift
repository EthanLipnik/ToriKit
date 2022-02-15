//
//  BaseRequest.swift
//  BaseRequest
//
//  Created by Ethan Lipnik on 7/24/21.
//

import Foundation

extension Tori {
    func createRequest(_ api: String, parameters: [URLQueryItem] = []) throws -> URLRequest {
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
        
        var urlParameters = [
            URLQueryItem(name: "oauth_token", value: accessToken),
            URLQueryItem(name: "oauth_consumer_key", value: request.consumerKey),
            URLQueryItem(name: "oauth_nonce", value: UUID().uuidString),
            URLQueryItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
            URLQueryItem(name: "oauth_timestamp", value: String(Int(Date().timeIntervalSince1970))),
            URLQueryItem(name: "oauth_version", value: "1.0")
        ] + parameters
        
        let signature = oAuthSignature(httpMethod: request.httpMethod,
                                       baseURLString: request.baseURLString,
                                       parameters: urlParameters,
                                       consumerSecret: request.consumerSecret,
                                       oAuthTokenSecret: accessTokenSecret)
        
        urlParameters.append(URLQueryItem(name: "oauth_signature", value: signature))
        
        var urlRequestComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        urlRequestComponents?.queryItems = parameters
        guard let url = urlRequestComponents?.url else { throw URLError(.badURL) }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod
        urlRequest.setValue(oAuthAuthorizationHeader(parameters: urlParameters),
                            forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
}
