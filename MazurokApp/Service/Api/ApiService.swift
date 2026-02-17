//
//  ApiService.swift
//  MazurokApp
//
//  Created by Andrii Mazurok on 09.02.2026.
//

import Foundation

final class ApiService {
    public static let sharedInstance = ApiService()
    
    private init() {}
    
    private let baseUrl = "http://localhost:8080"
    
    func getPosts(limit: Int, after: String?) async throws -> [Post] {
        var stringUrl = "\(baseUrl)/posts?limit=\(limit)"
        if let after  {
            stringUrl += "&after=\(after)"
        }
        let url = URL(string: stringUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decodedResponce = try JSONDecoder().decode(FetchPostResponce.self, from: data)
        
        return decodedResponce.posts
    }
}
