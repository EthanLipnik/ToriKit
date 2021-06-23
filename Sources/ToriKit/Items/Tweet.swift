//
//  Tweet.swift
//  Neptune
//
//  Created by Ethan Lipnik on 7/3/20.
//

import Foundation

public class Tweet: NSObject, Identifiable, Codable {
    public var id: String = UUID().uuidString
    public var text: String = ""
    public var user: User?
    public var isNSFW: Bool = false
    public var favorites: Int = 0
    public var retweets: Int = 0
    public var retweet: Tweet?
    public var isFavorited: Bool = false
    public var isRetweeted: Bool = false
    public var createdAt: Date = Date()
    public var source: String = ""
    public var quote: Tweet?
    public var quoteID: String?
    public var reply: Tweet?
    public var replyID: String?
    public var replyUser: String?
    public var language: String = "en"
    public var translation: String = ""
    public var entities: Entities?
    public var extendedEntities: Entities?
    public var permalinks: [Permalink]?
    
    public func like() {
        
        self.isFavorited = true
        
        self.favorites += 1
    }
    
    public func unlike() {
        self.isFavorited = false
        
        if self.favorites > 0 {
            self.favorites -= 1
        }
    }
    
    public func retweetTweet() {
        
        self.isRetweeted = true
        
        self.retweets += 1
    }
    
    public func unretweet() {
        
        self.isRetweeted = false
        
        if self.retweets > 0 {
            self.retweets -= 1
        }
    }
    
    public lazy var url: URL = {
        if let username = user?.username {
            return URL(string: "https://twitter.com/\(username)/status/\(id)") ?? URL(string: "https://twitter.com")!
        } else {
            return URL(string: "https://twitter.com")!
        }
    }()
    
    func readableTime() -> String {
        return self.createdAt.formatted(date: .omitted, time: .shortened)
//        let interval = self.createdAt.timeIntervalSinceNow
//        if interval.format(using: [.hour, .minute]) == "0h 0m" {
//            return "1m"
//        }
//
//        let time = interval.format(using: [.day, .minute, .hour])?.replacingOccurrences(of: "0d 0h 0m", with: "1m").replacingOccurrences(of: "0d", with: "").replacingOccurrences(of: "0h", with: "").replacingOccurrences(of: "0m", with: "").replacingOccurrences(of: "0m", with: "")
//        let components = time?.components(separatedBy: " ").filter({ !$0.isEmpty })
//        return (components?.first ?? time ?? "—").replacingOccurrences(of: "-", with: "")
    }
    
    override init() { }
    
    static func == (lhs: Tweet, rhs: Tweet) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(favorites, forKey: .favorites)
        try container.encode(retweets, forKey: .retweets)
        try container.encode(isFavorited, forKey: .isFavorited)
        try container.encode(isRetweeted, forKey: .isRetweeted)
        try container.encode(dateFormatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(source, forKey: .source)
        try container.encode(isNSFW, forKey: .isNSFW)
        try container.encode(quoteID, forKey: .quoteID)
        try container.encode(quote, forKey: .quote)
        try container.encode(replyID, forKey: .replyID)
        try container.encode(language, forKey: .language)
        try container.encode(entities, forKey: .entities)
        try container.encode(extendedEntities, forKey: .extendedEntities)
        try container.encode(user, forKey: .user)
        try container.encode(permalinks, forKey: .permalinks)
        try container.encode(retweet, forKey: .retweet)
        try container.encode(replyUser, forKey: .replyUser)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_str"
        case text = "full_text"
        case favorites = "favorite_count"
        case favoritesGB = "favourites_count"
        case retweets = "retweet_count"
        case isFavorited = "favorited"
        case isRetweeted = "retweeted"
        case createdAt = "created_at"
        case source
        case isNSFW = "possibly_sensitive"
        case quoteID = "quoted_status_id_str"
        case replyID = "in_reply_to_status_id_str"
        case language = "lang"
        case entities
        case extendedEntities = "extended_entities"
        case user
        case permalinks = "quoted_status_permalink"
        case retweet = "retweeted_status"
        case replyUser = "in_reply_to_screen_name"
        case quote
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        text = (try? container.decode(String.self, forKey: .text))?.stringByDecodingHTMLEntities ?? "Couldn't decode"
        user = try container.decode(User.self, forKey: .user)
        isNSFW = (try? container.decode(Bool.self, forKey: .isNSFW)) ?? false
        favorites = Int(((try? container.decode(Float.self, forKey: .favorites)) ?? (try? container.decode(Float.self, forKey: .favoritesGB))) ?? 0)
        retweets = Int(try container.decode(Float.self, forKey: .retweets))
        isFavorited = try container.decode(Bool.self, forKey: .isFavorited)
        isRetweeted = try container.decode(Bool.self, forKey: .isRetweeted)
        retweet = try? container.decode(Tweet.self, forKey: .retweet)
        entities = try? container.decode(Entities.self, forKey: .entities)
        extendedEntities = try? container.decode(Entities.self, forKey: .extendedEntities)
        
        let dateStr = try container.decode(String.self, forKey: .createdAt)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        
        createdAt = dateFormatter.date(from: dateStr) ?? Date()
        
        source = try container.decode(String.self, forKey: .source)/*.components(separatedBy: ">")[1].replacingOccurrences(of: "</a", with: "")*/
        quoteID = try? container.decode(String.self, forKey: .quoteID)
        
        if let quoteURL = try? container.decode(Permalink.self, forKey: .permalinks) {
            permalinks = [quoteURL]
        } else {
            permalinks = []
        }
        
        if let quote = try? container.decode(Tweet.self, forKey: .quote) {
            self.quote = quote
        }
        
        replyID = try? container.decode(String.self, forKey: .replyID)
        replyUser = try? container.decode(String.self, forKey: .replyUser)
    }
}

extension TimeInterval {
    func format(using units: NSCalendar.Unit) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: self)
    }
}

private let characterEntities : [ Substring : Character ] = [
    // XML predefined entities:
    "&quot;"    : "\"",
    "&amp;"     : "&",
    "&apos;"    : "'",
    "&lt;"      : "<",
    "&gt;"      : ">",

    // HTML character entity references:
    "&nbsp;"    : "\u{00a0}",
    // ...
    "&diams;"   : "♦",
]

extension String {

    /// Returns a new string made by replacing in the `String`
    /// all HTML character entity references with the corresponding
    /// character.
    var stringByDecodingHTMLEntities : String {

        // ===== Utility functions =====

        // Convert the number in the string to the corresponding
        // Unicode character, e.g.
        //    decodeNumeric("64", 10)   --> "@"
        //    decodeNumeric("20ac", 16) --> "€"
        func decodeNumeric(_ string : Substring, base : Int) -> Character? {
            guard let code = UInt32(string, radix: base),
                let uniScalar = UnicodeScalar(code) else { return nil }
            return Character(uniScalar)
        }

        // Decode the HTML character entity to the corresponding
        // Unicode character, return `nil` for invalid input.
        //     decode("&#64;")    --> "@"
        //     decode("&#x20ac;") --> "€"
        //     decode("&lt;")     --> "<"
        //     decode("&foo;")    --> nil
        func decode(_ entity : Substring) -> Character? {

            if entity.hasPrefix("&#x") || entity.hasPrefix("&#X") {
                return decodeNumeric(entity.dropFirst(3).dropLast(), base: 16)
            } else if entity.hasPrefix("&#") {
                return decodeNumeric(entity.dropFirst(2).dropLast(), base: 10)
            } else {
                return characterEntities[entity]
            }
        }

        // ===== Method starts here =====

        var result = ""
        var position = startIndex

        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = self[position...].range(of: "&") {
            result.append(contentsOf: self[position ..< ampRange.lowerBound])
            position = ampRange.lowerBound

            // Find the next ';' and copy everything from '&' to ';' into `entity`
            guard let semiRange = self[position...].range(of: ";") else {
                // No matching ';'.
                break
            }
            let entity = self[position ..< semiRange.upperBound]
            position = semiRange.upperBound

            if let decoded = decode(entity) {
                // Replace by decoded character:
                result.append(decoded)
            } else {
                // Invalid entity, copy verbatim:
                result.append(contentsOf: entity)
            }
        }
        // Copy remaining characters to `result`:
        result.append(contentsOf: self[position...])
        return result
    }
}
