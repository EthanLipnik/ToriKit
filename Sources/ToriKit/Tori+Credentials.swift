//
//  Tori+Credentials.swift
//  
//
//  Created by Ethan Lipnik on 6/8/21.
//

import Foundation

extension Tori {
    public struct Credentials {
        public var consumerKey: String
        public var consumerSecret: String
        public var callback: String
        
        public init(consumerKey: String, consumerSecret: String, callback: String) {
            self.consumerKey = consumerKey
            self.consumerSecret = consumerSecret
            self.callback = callback
        }
    }
}
