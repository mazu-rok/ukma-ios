//
//  StorageManager.swift
//  MazurokApp
//
//  Created by Andrii Mazurok on 24.02.2026.
//

import Foundation

class StorageManager {
    public static let sharedInstance = StorageManager()
    private let fileName = "saved_posts.json"
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var fileURL: URL {
        documentsDirectory.appendingPathComponent(fileName)
    }
    
    func savePosts(_ posts: [Post]?) {
        do {
            let data = try JSONEncoder().encode(posts)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        } catch {
            print("Error saving: \(error)")
        }
    }
    
    func loadPosts() -> [Post] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([Post].self, from: data)
        } catch {
            print("Error loading: \(error)")
            return []
        }
    }
}
