//
//  Tori+UploadMedia.swift
//  
//
//  Created by Ethan Lipnik on 2/17/22.
//

import Foundation

//extension Tori {
//    public enum MediaType: String {
//        case png = "image/png"
//        case jpeg = "image/jpeg"
//        case gif = "image/gif"
//        case mov = "video/mov"
//        case mp4 = "video/mp4"
//    }
//    
//    public enum MediaCategory: String {
//        case gif = "tweet_gif"
//        case video = "tweet_video"
//    }
//    
//    internal struct MediaResponse: Codable {
//        var mediaIdString: String
//        
//        enum CodingKeys: String, CodingKey {
//            case mediaIdString = "media_id_string"
//        }
//    }
//    
//    @discardableResult internal func initUpload(data: Data, type: MediaType, category: MediaCategory) async throws -> URLResponse {
//        let request = try createRequest("media", api: "upload", parameters: [
//            URLQueryItem(name: "command", value: "INIT"),
//            URLQueryItem(name: "total_bytes", value: "\(data.count)"),
//            URLQueryItem(name: "media_type", value: type.rawValue),
//            URLQueryItem(name: "media_category", value: category.rawValue)
//        ], method: .post)
//        
//        let data = try await URLSession.shared.data(for: request).0
//        return try JSONDecoder().decode(MediaResponse.self, from: data)
//    }
//    
//    internal func appendUpload(mediaId: String, data: Data, name: String? = nil, index: Int = 0) {
//        let chunkSize: Int = 2 * 1024 * 1024
//        let location = index * chunkSize
//        let length: Int = (data.count < chunkSize) ? data.count : min(data.count - location, chunkSize)
//        let range: Range<Data.Index> = (location ..< location + length)
//        let subData = data.subdata(in: range)
//        
//        let request = try createRequest("media", api: "upload", parameters: [
//            URLQueryItem(name: "command", value: "APPEND"),
//            URLQueryItem(name: "media_id", value: mediaId),
//            URLQueryItem(name: "segment_index", value: index),
//            URLQueryItem(name: "media": subData)
//        ], method: .post)
//        
//        return try await URLSession.shared.data(for: request).1
//    }
//}
