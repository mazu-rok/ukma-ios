//
//  Post.swift
//  MazurokApp
//
//  Created by Andrii Mazurok on 09.02.2026.
//

import Foundation

struct Post: Codable, Equatable, Hashable {
    var id: String
    var ups: Int
    var downs: Int
    var username: String
    var domain: String
    var title: String
    var text: String
    var created_at: Double
    var image_url: String
    var comments: [Comment]
    var saved: Bool?
    
    /*init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.ups = try container.decode(Int.self, forKey: .ups)
        self.downs = try container.decode(Int.self, forKey: .downs)
        self.username = try container.decode(String.self, forKey: .username)
        self.domain = try container.decode(String.self, forKey: .domain)
        self.title = try container.decode(String.self, forKey: .title)
        self.text = try container.decode(String.self, forKey: .text)
        let timestamp = try container.decode(Double.self, forKey: .created_at)
        self.created_at = Date(timeIntervalSince1970: timestamp)
        self.image_url = try container.decode(String.self, forKey: .image_url)
        self.comments = try container.decode([Comment].self, forKey: .comments)
        self.saved = try container.decodeIfPresent(Bool.self, forKey: .saved) ?? false
    }*/
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct FetchPostResponce: Decodable {
    var posts: [Post]
    var after: String?
}
