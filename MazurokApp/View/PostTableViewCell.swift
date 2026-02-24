//
//  PostTableViewCell.swift
//  MazurokApp
//
//  Created by Andrii Mazurok on 15.02.2026.
//

import UIKit
import SDWebImage

class PostTableViewCell: UITableViewCell {
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var domainLabel: UILabel!
    @IBOutlet private weak var bookmarkButton: UIButton!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var postImage: UIImageView!
    
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var commentsLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!
    
    private var onShareButtonTapped: (() -> Void)!
    private var onSaveButtonTapped: ((Bool) -> Void)!
    
    private var saved: Bool!
    
    func configure(with post: Post, onShareButtonTapped: @escaping () -> Void, onSaveButtonTapped: @escaping (Bool) -> Void) {
        usernameLabel.text = post.username
        domainLabel.text = post.domain
        timeLabel.text = calculateTimePassed(from: post.created_at)
        titleLabel.text = post.title
        commentsLabel.text = "\(post.comments.count)"
        ratingLabel.text = "\(post.ups + post.downs)"
        saved = post.saved ?? false
        self.onShareButtonTapped = onShareButtonTapped
        self.onSaveButtonTapped = onSaveButtonTapped
        updateBookmarkButton()
        
        if let imageUrl = URL(string: post.image_url) {
            postImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
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
    
    @IBAction private func bookmarkButtonTapped() {
        saved.toggle()
        updateBookmarkButton()
        onSaveButtonTapped(saved)
    }
    
    @IBAction private func sharedButtonTapped() {
        onShareButtonTapped()
    }
}
