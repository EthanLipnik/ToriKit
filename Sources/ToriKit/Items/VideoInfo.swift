//
//  VideoInfo.swift
//  Neptune
//
//  Created by Ethan Lipnik on 7/4/20.
//

import Foundation

public struct VideoInfo: Codable, Hashable {
    public var aspectRatio: [Double] = []
    public var variants: [VideoVariants] = []
    
    private enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case variants
    }
}

public struct VideoVariants: Codable, Hashable {
    public var url: URL?
    public var contentType: String?
    public var bitrate: Float?
    
    private enum CodingKeys: String, CodingKey {
        case url
        case contentType = "content_type"
        case bitrate
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.url = try? container.decode(URL.self, forKey: .url)
        self.contentType = try? container.decode(String.self, forKey: .contentType)
        self.bitrate = try? container.decode(Float.self, forKey: .bitrate)
    }
}
