//
//  Entities.swift
//  Neptune
//
//  Created by Ethan Lipnik on 7/4/20.
//

import Foundation

public struct Entities: Codable, Hashable {
    public var media: [Media] = []
    public var urls: [TwitterURL] = []
    
    private enum CodingKeys: String, CodingKey {
        case media
        case urls
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.media = (try? container.decode([Media].self, forKey: .media)) ?? []
        self.urls = (try? container.decode([TwitterURL].self, forKey: .urls)) ?? []
    }
}
