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
    
    private var post: Post!
    
    private var saved: Bool!
    
    private var onShareButtonTapped: (() -> Void)!
    private var onSaveButtonTapped: ((Bool) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPostView()
    }
    
    func setPost(_ post: Post, onShareButtonTapped: @escaping () -> Void, onSaveButtonTapped: @escaping (Bool) -> Void) {
        self.post = post
        self.onShareButtonTapped = onShareButtonTapped
        self.onSaveButtonTapped = onSaveButtonTapped
    }
    
    @IBAction private func bookmarkButtonTapped() {
        saved.toggle()
        updateBookmarkButton()
        onSaveButtonTapped(saved)
    }
    
    @IBAction private func sharedButtonTapped() {
        onShareButtonTapped()
    }
    
    private func setupPostView() {
        usernameLabel.text = post.username
        domainLabel.text = post.domain
        titleLabel.text = post.title
        commentsLabel.text = "\(post.comments.count)"
        ratingLabel.text = "\(post.ups + post.downs)"
        timeLabel.text = calculateTimePassed(from: post.created_at)
        saved = post.saved ?? false
        postView.isHidden = false
        updateBookmarkButton()
        
        if let imageUrl = URL(string: post.image_url) {
            image.sd_setImage(with: imageUrl)
        }
    }
    
    private func updateBookmarkButton() {
        let image = UIImage(systemName: saved ? "bookmark.fill" : "bookmark")
        bookmarkButton.setImage(image, for: .normal)
    }

    private func calculateTimePassed(from timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        
        let now = Date()
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        
        return formatter.localizedString(for: date, relativeTo: now)
    }
}
