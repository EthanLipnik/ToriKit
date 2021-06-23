//
//  File.swift
//  
//
//  Created by Ethan Lipnik on 6/8/21.
//

import Foundation
import CommonCrypto
import Combine
import KeychainAccess

extension Tori {
    @discardableResult public func authorize() -> Future<(user: Account, tokens: TokenCredentials), Error> {
        
        return Future { promise in
            
            guard !self.authorizationSheetIsPresented else { promise(.failure(URLError(.httpTooManyRedirects))); return }
            
            self.authorizationSheetIsPresented = true
            self.subscriptions["oAuthRequestTokenSubscriber"] =
            self.oAuthRequestTokenPublisher()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: ()
                    case .failure(_):
                        // Handle Errors
                        self.authorizationSheetIsPresented = false
                    }
                    self.subscriptions.removeValue(forKey: "oAuthRequestTokenSubscriber")
                }, receiveValue: { [weak self] temporaryCredentials in
                    guard let self = self else { return }
                    
                    guard let authorizationURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(temporaryCredentials.requestToken)")
                    else { return }
                    
                    self.authorizationURL = authorizationURL
                    
                    self.subscriptions["onOAuthRedirect"] =
                    self.onOAuthRedirect
                        .sink(receiveValue: { [weak self] url in
                            guard let self = self else { return }
                            
                            self.subscriptions.removeValue(forKey: "onOAuthRedirect")
                            
                            self.authorizationSheetIsPresented = false
                            self.authorizationURL = nil
                            
                            if let parameters = url.query?.urlQueryItems {
                                guard let oAuthToken = parameters["oauth_token"],
                                      let oAuthVerifier = parameters["oauth_verifier"]
                                else {
                                    // Handle error for unexpected response
                                    return
                                }
                                
                                if oAuthToken != temporaryCredentials.requestToken {
                                    // Handle error for tokens do not match
                                    return
                                }
                                
                                self.subscriptions["oAuthAccessTokenSubscriber"] =
                                self.oAuthAccessTokenPublisher(temporaryCredentials: temporaryCredentials,
                                                               verifier: oAuthVerifier)
                                    .receive(on: DispatchQueue.main)
                                    .sink(receiveCompletion: { _ in
                                        // Error handler
                                    }, receiveValue: { [weak self] (tokenCredentials, user) in
                                        guard let self = self else { return }
                                        
                                        self.subscriptions.removeValue(forKey: "oAuthRequestTokenSubscriber")
                                        self.subscriptions.removeValue(forKey: "onOAuthRedirect")
                                        self.subscriptions.removeValue(forKey: "oAuthAccessTokenSubscriber")
                                        
                                        self.tokenCredentials = tokenCredentials
                                        self.user = user
                                        
                                        promise(.success((user, tokenCredentials)))
                                    })
                            }
                        })
                })
        }
    }
    
    private struct TemporaryCredentials {
        let requestToken: String
        let requestTokenSecret: String
    }
    
    public enum OAuthError: Error {
        case unknown
        case urlError(URLError)
        case httpURLResponse(Int)
        case cannotDecodeRawData
        case cannotParseResponse
        case unexpectedResponse
        case failedToConfirmCallback
    }
    
    public struct TokenCredentials: Codable {
        public let accessToken: String
        public let accessTokenSecret: String
        
        public init(accessToken: String, accessTokenSecret: String) {
            self.accessToken = accessToken
            self.accessTokenSecret = accessTokenSecret
        }
        
        public static func `optional`(accessToken: String?, accessTokenSecret: String?) -> TokenCredentials? {
            guard let accessToken = accessToken, let accessTokenSecret = accessTokenSecret else { return nil }

            return TokenCredentials(accessToken: accessToken, accessTokenSecret: accessTokenSecret)
        }
    }
    
    public struct Account: Codable {
        public let ID: String
        public let screenName: String
        
        public static func `optional`(id: String?, screenName: String?) -> Account? {
            guard let id = id, let screenName = screenName else { return nil }
            return Account(ID: id, screenName: screenName)
        }
    }
    
    private func oAuthAccessTokenPublisher(temporaryCredentials: TemporaryCredentials, verifier: String) -> AnyPublisher<(TokenCredentials, Account), OAuthError> {
        let request = (baseURLString: "https://api.twitter.com/oauth/access_token",
                       httpMethod: "POST",
                       consumerKey: credentials.consumerKey,
                       consumerSecret: credentials.consumerSecret)
        
        guard let baseURL = URL(string: request.baseURLString) else {
            return Fail(error: OAuthError.urlError(URLError(.badURL)))
                .eraseToAnyPublisher()
        }
        
        var parameters = [
            URLQueryItem(name: "oauth_token", value: temporaryCredentials.requestToken),
            URLQueryItem(name: "oauth_verifier", value: verifier),
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
                                       oAuthTokenSecret: temporaryCredentials.requestTokenSecret)
        
        parameters.append(URLQueryItem(name: "oauth_signature", value: signature))
        
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = request.httpMethod
        urlRequest.setValue(oAuthAuthorizationHeader(parameters: parameters),
                            forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response -> (TokenCredentials, Account) in
                guard let response = response as? HTTPURLResponse
                else { throw OAuthError.unknown }
                
                guard response.statusCode == 200
                else { throw OAuthError.httpURLResponse(response.statusCode) }
                
                guard let parameterString = String(data: data, encoding: .utf8)
                else { throw OAuthError.cannotDecodeRawData }
                
                if let parameters = parameterString.urlQueryItems {
                    guard let oAuthToken = parameters.value(for: "oauth_token"),
                          let oAuthTokenSecret = parameters.value(for: "oauth_token_secret"),
                          let userID = parameters.value(for: "user_id"),
                          let screenName = parameters.value(for: "screen_name")
                    else {
                        throw OAuthError.unexpectedResponse
                    }
                    
                    return (TokenCredentials(accessToken: oAuthToken,
                                             accessTokenSecret: oAuthTokenSecret),
                            Account(ID: userID,
                                 screenName: screenName))
                } else {
                    throw OAuthError.cannotParseResponse
                }
            }
            .mapError { error -> OAuthError in
                switch (error) {
                case let oAuthError as OAuthError:
                    return oAuthError
                default:
                    return OAuthError.unknown
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func oAuthRequestTokenPublisher() -> AnyPublisher<TemporaryCredentials, OAuthError> {
        // 1
        let request = (baseURLString: "https://api.twitter.com/oauth/request_token",
                       httpMethod: "POST",
                       consumerKey: credentials.consumerKey,
                       consumerSecret: credentials.consumerSecret,
                       callbackURLString: "\(credentials.callback)://")
        
        // 2
        guard let baseURL = URL(string: request.baseURLString) else {
            return Fail(error: OAuthError.urlError(URLError(.badURL)))
                .eraseToAnyPublisher()
        }
        
        // 3
        var parameters = [
            URLQueryItem(name: "oauth_callback", value: request.callbackURLString),
            URLQueryItem(name: "oauth_consumer_key", value: request.consumerKey),
            URLQueryItem(name: "oauth_nonce", value: UUID().uuidString),
            URLQueryItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
            URLQueryItem(name: "oauth_timestamp", value: String(Int(Date().timeIntervalSince1970))),
            URLQueryItem(name: "oauth_version", value: "1.0")
        ]
        
        // 4
        let signature = oAuthSignature(httpMethod: request.httpMethod,
                                       baseURLString: request.baseURLString,
                                       parameters: parameters,
                                       consumerSecret: request.consumerSecret)
        
        // 5
        parameters.append(URLQueryItem(name: "oauth_signature", value: signature))
        
        // 6
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = request.httpMethod
        urlRequest.setValue(oAuthAuthorizationHeader(parameters: parameters),
                            forHTTPHeaderField: "Authorization")
        
        //7
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
        // 8
            .tryMap { data, response -> TemporaryCredentials in
                // 9
                guard let response = response as? HTTPURLResponse
                else { throw OAuthError.unknown }
                
                // 10
                guard response.statusCode == 200
                else { throw OAuthError.httpURLResponse(response.statusCode) }
                
                // 11
                guard let parameterString = String(data: data, encoding: .utf8)
                else { throw OAuthError.cannotDecodeRawData }
                
                // 12
                if let parameters = parameterString.urlQueryItems {
                    // 13
                    guard let oAuthToken = parameters["oauth_token"],
                          let oAuthTokenSecret = parameters["oauth_token_secret"],
                          let oAuthCallbackConfirmed = parameters["oauth_callback_confirmed"]
                    else {
                        throw OAuthError.unexpectedResponse
                    }
                    
                    // 14
                    if oAuthCallbackConfirmed != "true" {
                        throw OAuthError.failedToConfirmCallback
                    }
                    
                    // 15
                    return TemporaryCredentials(requestToken: oAuthToken,
                                                requestTokenSecret: oAuthTokenSecret)
                } else {
                    throw OAuthError.cannotParseResponse
                }
            }
        // 16
            .mapError { error -> OAuthError in
                switch (error) {
                case let oAuthError as OAuthError:
                    return oAuthError
                default:
                    return OAuthError.unknown
                }
            }
        // 17
            .eraseToAnyPublisher()
    }
    
    private func oAuthSignatureBaseString(httpMethod: String,
                                          baseURLString: String,
                                          parameters: [URLQueryItem]) -> String {
        var parameterComponents: [String] = []
        for parameter in parameters {
            let name = parameter.name.oAuthURLEncodedString
            let value = parameter.value?.oAuthURLEncodedString ?? ""
            parameterComponents.append("\(name)=\(value)")
        }
        let parameterString = parameterComponents.sorted().joined(separator: "&")
        return httpMethod + "&" +
        baseURLString.oAuthURLEncodedString + "&" +
        parameterString.oAuthURLEncodedString
    }
    
    private func oAuthSigningKey(consumerSecret: String,
                                 oAuthTokenSecret: String?) -> String {
        if let oAuthTokenSecret = oAuthTokenSecret {
            return consumerSecret.oAuthURLEncodedString + "&" +
            oAuthTokenSecret.oAuthURLEncodedString
        } else {
            return consumerSecret.oAuthURLEncodedString + "&"
        }
    }
    
    public func oAuthSignature(httpMethod: String,
                                baseURLString: String,
                                parameters: [URLQueryItem],
                                consumerSecret: String,
                                oAuthTokenSecret: String? = nil) -> String {
        let signatureBaseString = oAuthSignatureBaseString(httpMethod: httpMethod,
                                                           baseURLString: baseURLString,
                                                           parameters: parameters)
        
        let signingKey = oAuthSigningKey(consumerSecret: consumerSecret,
                                         oAuthTokenSecret: oAuthTokenSecret)
        
        return signatureBaseString.hmacSHA1Hash(key: signingKey)
    }
    
    public func oAuthAuthorizationHeader(parameters: [URLQueryItem]) -> String {
        var parameterComponents: [String] = []
        for parameter in parameters {
            let name = parameter.name.oAuthURLEncodedString
            let value = parameter.value?.oAuthURLEncodedString ?? ""
            parameterComponents.append("\(name)=\"\(value)\"")
        }
        return "OAuth " + parameterComponents.sorted().joined(separator: ", ")
    }
}


extension CharacterSet {
    static var urlRFC3986Allowed: CharacterSet {
        CharacterSet(charactersIn: "-_.~").union(.alphanumerics)
    }
}

extension String {
    var oAuthURLEncodedString: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlRFC3986Allowed) ?? self
    }
    
    var urlQueryItems: [URLQueryItem]? {
        URLComponents(string: "://?\(self)")?.queryItems
    }
    
    func hmacSHA1Hash(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1),
               key,
               key.count,
               self,
               self.count,
               &digest)
        return Data(digest).base64EncodedString()
    }
}

extension Array where Element == URLQueryItem {
    func value(for name: String) -> String? {
        return self.filter({$0.name == name}).first?.value
    }
    
    subscript(name: String) -> String? {
        return value(for: name)
    }
}

infix operator +|

func +| <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>) -> Dictionary<K,V> {
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}
