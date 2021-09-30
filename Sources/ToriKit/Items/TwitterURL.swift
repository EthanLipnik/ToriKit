//
//  TwitterURL.swift
//  Neptune
//
//  Created by Ethan Lipnik on 7/4/20.
//

import Foundation

public struct TwitterURL: Codable, Hashable {
    public var url: URL?
    public var displayURL: URL?
    public var expandedURL: URL?
    
    private enum CodingKeys: String, CodingKey {
        case url
        case displayURL = "display_url"
        case expandedURL = "expanded_url"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.url = try? container.decode(URL.self, forKey: .url)
        self.displayURL = try? container.decode(URL.self, forKey: .displayURL)
        self.expandedURL = try? container.decode(URL.self, forKey: .expandedURL)
    }
}
