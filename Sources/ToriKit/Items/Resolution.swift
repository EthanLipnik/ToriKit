//
//  Resolution.swift
//  Neptune
//
//  Created by Ethan Lipnik on 7/4/20.
//

import Foundation

public struct Resolution: Codable, Hashable {
    public var width: Float?
    public var height: Float?
    
    private enum CodingKeys: String, CodingKey {
        case width = "w"
        case height = "h"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.width = try? container.decode(Float.self, forKey: .width)
        self.height = try? container.decode(Float.self, forKey: .height)
    }
}
