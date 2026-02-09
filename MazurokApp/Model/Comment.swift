//
//  Coment.swift
//  MazurokApp
//
//  Created by Andrii Mazurok on 09.02.2026.
//

struct Comment: Codable {
    var id: String
    var ups: Int
    var post_id: String
    var downs: Int
    var text: String
    var username: String
}
