//
//  Trend.swift
//  Neptune
//
//  Created by Ethan Lipnik on 10/5/20.
//

import Foundation

public struct Trend: Codable, Equatable, Hashable, Identifiable {
    public var id: String {
        return url.absoluteString
    }
    
    public var name: String
    public var tweetVolume: Int? = nil
    public var url: URL
    
    enum CodingKeys: String, CodingKey {
        case name
        case url
        case tweetVolume = "tweet_volume"
    }
}
