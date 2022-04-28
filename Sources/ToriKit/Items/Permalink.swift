//
//  Permalink.swift
//  Neptune
//
//  Created by Ethan Lipnik on 7/4/20.
//

import Foundation

public struct Permalink: Codable, Hashable {
    public var url: URL
    public var expanded: URL?
    public var display: URL?
}
