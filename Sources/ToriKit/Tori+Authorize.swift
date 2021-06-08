//
//  File.swift
//  
//
//  Created by Ethan Lipnik on 6/8/21.
//

import Foundation
import CommonCrypto

extension Tori {
    func authorize() async throws -> String {
        
        return try await oAuthRequestTokenPublisher().requestToken
    }
    
    private struct TemporaryCredentials {
        let requestToken: String
        let requestTokenSecret: String
    }
    
    enum OAuthError: Error {
        case unknown
        case urlError(URLError)
        case httpURLResponse(Int)
        case cannotDecodeRawData
        case cannotParseResponse
        case unexpectedResponse
        case failedToConfirmCallback
    }
    
    private func oAuthRequestTokenPublisher() async throws -> TemporaryCredentials {
        // 1
        let request = (baseURLString: "https://api.twitter.com/oauth/request_token",
                       httpMethod: "POST",
                       consumerKey: credentials.consumerKey,
                       consumerSecret: credentials.consumerSecret,
                       callbackURLString: "\(credentials.callback)://")
        
        // 2
        guard let baseURL = URL(string: request.baseURLString) else {
            throw OAuthError.urlError(URLError(.badURL))
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
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
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
    
    private func oAuthSignature(httpMethod: String,
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
    
    private func oAuthAuthorizationHeader(parameters: [URLQueryItem]) -> String {
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
