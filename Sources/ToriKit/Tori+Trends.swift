//
//  Tori+Trends.swift
//  
//
//  Created by Ethan Lipnik on 10/6/21.
//

import Foundation

extension Tori {
    public func getTrends() async throws -> [Trend] {
        let request = try createRequest("trends",
                                        api: "closest",
                                        parameters: [
                                            URLQueryItem(name: "lat", value: "\(0)"),
                                            URLQueryItem(name: "long", value: "\(0)")
                                        ])

        let data = try await URLSession.shared.data(for: request).0
        return try JSONDecoder().decode([Trend].self, from: data)
    }
}
