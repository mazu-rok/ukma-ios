//
//  PostViewController.swift
//  MazurokApp
//
//  Created by Andrii Mazurok on 06.02.2026.
//

import UIKit
import SDWebImage

class PostViewController: UIViewController {
    @IBOutlet private weak var postView: UIView!
    
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var domainLabel: UILabel!
    @IBOutlet private weak var bookmarkButton: UIButton!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var image: UIImageView!
    
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var commentsLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!
    
    private var saved: Bool = Bool.random()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postView.isHidden = true
        updateBookmarkButton()
        fetchPosts()
    }
    
    @IBAction private func bookmarkButtonTapped() {
        saved.toggle()
        updateBookmarkButton()
    }
    
    @IBAction private func sharedButtonTapped() {
        
    }
    
    private func fetchPosts() {
        Task {
            do {
                let posts = try await ApiService.sharedInstance.getPosts(limit: 1)
                guard let fistPost = posts.first else {
                    print("First post is empty")
                    return
                }
                
                DispatchQueue.main.async {
                    self.updatePostView(post: fistPost)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    private func updatePostView(post: Post) {
        usernameLabel.text = post.username
        domainLabel.text = post.domain
        titleLabel.text = post.title
        commentsLabel.text = "\(post.comments.count)"
        ratingLabel.text = "\(post.ups + post.downs)"
        timeLabel.text = calculateTimePassed(from: post.created_at)
        postView.isHidden = false
        
        if let imageUrl = URL(string: post.image_url) {
            image.sd_setImage(with: imageUrl)
        }
    }
    
    private func updateBookmarkButton() {
        let image = UIImage(systemName: saved ? "bookmark.fill" : "bookmark")
        bookmarkButton.setImage(image, for: .normal)
    }

    private func calculateTimePassed(from date: Date) -> String {
        let now = Date()
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        
        return formatter.localizedString(for: date, relativeTo: now)
    }
}
