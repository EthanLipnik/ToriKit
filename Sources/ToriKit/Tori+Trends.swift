//
//  Tori+Trends.swift
//  
//
//  Created by Ethan Lipnik on 10/6/21.
//

import Foundation

extension Tori {
    public func getTrends() async throws -> [Trend] {
        return try await withCheckedThrowingContinuation({ continuation in
            swifter?.getClosestTrends(for: (0, 0), success: { json in
                guard let data = "\(json)".data(using: .utf8) else { continuation.resume(throwing: URLError(.badServerResponse)); return }
                
                do {
                    let trends = try JSONDecoder().decode([Trend].self, from: data)
                    continuation.resume(returning: trends)
                } catch {
                    continuation.resume(throwing: error)
                }
            }, failure: { error in
                continuation.resume(throwing: error)
            })
        })
    }
}
