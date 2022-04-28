//
//  Media.swift
//  Neptune
//
//  Created by Ethan Lipnik on 7/4/20.
//

import Foundation

public struct Media: Identifiable, Codable, Hashable {
    public var id: String = UUID().uuidString
    public var url: URL?
    public var textURL: URL?
    public var sizes: Sizes?
    public var type: String = ""
    public var videoInfo: VideoInfo?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_str"
        case url = "media_url_https"
        case textURL = "url"
        case sizes
        case type
        case videoInfo = "video_info"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        url = try container.decode(URL.self, forKey: .url)
        textURL = try container.decode(URL.self, forKey: .textURL)
        sizes = try container.decode(Sizes.self, forKey: .sizes)
        type = try container.decode(String.self, forKey: .type)
        
        videoInfo = try? container.decode(VideoInfo.self, forKey: .videoInfo)
    }
}
