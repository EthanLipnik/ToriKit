//
//  UserIdentifer.swift
//  
//
//  Created by Ethan Lipnik on 2/15/22.
//

import Foundation

extension Tori {
    public enum UserIdentifer {
        case id(_ userID: String)
        case screenName(_ screenName: String)
        
        public func queryItem() -> URLQueryItem {
            switch self {
            case .id(let id):
                return URLQueryItem(name: "user_id", value: id)
            case .screenName(let screenName):
                return URLQueryItem(name: "screen_name", value: screenName)
            }
        }
        
        public var value: String {
            get {
                switch self {
                case .id(let id):
                    return id
                case .screenName(let screenName):
                    return screenName
                }
            }
        }
    }
}
