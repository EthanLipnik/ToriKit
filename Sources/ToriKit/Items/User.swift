//
//  User.swift
//  Neptune
//
//  Created by Ethan Lipnik on 7/3/20.
//

import Foundation

public class User: NSObject, Identifiable, Codable {
    public var id: String = UUID().uuidString
    public var name: String
    public var username: String
    public var picture: URL
    public var banner: URL?
    public var profileDescription: String
    public var location: String
    public var createdAt: String
    public var isVerified: Bool
    public var followers: Int
    public var followings: Int
    public var isFollowing: Bool
    public var isPrivate: Bool
    
    public var url: URL {
        return URL(string: "https://twitter.com/\(username)")!
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id_str"
        case name
        case username = "screen_name"
        case profileDescription = "description"
        case picture = "profile_image_url_https"
        case location
        case createdAt = "created_at"
        case isVerified = "verified"
        case banner = "profile_banner_url"
        case followers = "followers_count"
        case followings = "friends_count"
        case isFollowing = "following"
        case isPrivate = "protected"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        profileDescription = try container.decode(String.self, forKey: .profileDescription)
        picture = try container.decode(URL.self, forKey: .picture)
        location = try container.decode(String.self, forKey: .location)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        isVerified = try container.decode(Bool.self, forKey: .isVerified)
        banner = try? container.decode(URL.self, forKey: .banner)
        followers = Int(try container.decode(Float.self, forKey: .followers))
        followings = Int(try container.decode(Float.self, forKey: .followings))
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        
        isFollowing = (try? container.decode(Bool.self, forKey: .isFollowing)) ?? false
    }
}

extension URL {
    public func highResPicture() -> URL? {
        return URL(string: self.absoluteString.replacingOccurrences(of: "_normal", with: ""))
    }
}
