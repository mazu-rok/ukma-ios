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
    private var bookmarkLayer: CAShapeLayer!
    
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var commentsLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!
    
    private var onShareButtonTapped: (() -> Void)!
    private var onSaveButtonTapped: ((Bool) -> Void)!
    
    private var saved: Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        postImage.isUserInteractionEnabled = true
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        
        doubleTap.cancelsTouchesInView = true
        doubleTap.delaysTouchesBegan = true
        postImage.addGestureRecognizer(doubleTap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bookmarkLayer?.position = CGPoint(x: postImage.bounds.midX,
                                          y: postImage.bounds.midY)
    }

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
        bookmarkLayer = createBookmarkLayer(in: postImage)
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

    @objc func handleDoubleTap() {
        bookmarkButtonTapped()
        bookmarkLayer.fillColor = saved ? UIColor.white.withAlphaComponent(0.8).cgColor : UIColor.clear.cgColor
        animateBookmarkIcon()
    }

    private func createBookmarkLayer(in view: UIView) -> CAShapeLayer {
        let width: CGFloat = 60
        let height: CGFloat = 80
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width / 2, y: height * 0.75))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.close()
        
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.withAlphaComponent(0.8).cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.opacity = 0
        shapeLayer.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        view.layer.addSublayer(shapeLayer)

        return shapeLayer
    }

    private func animateBookmarkIcon() {
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0, 1, 1, 0]
        opacityAnimation.keyTimes = [0, 0.4, 0.8, 1]
        opacityAnimation.duration = 0.75
        opacityAnimation.isRemovedOnCompletion = true
        
        bookmarkLayer.add(opacityAnimation, forKey: "bookmarkIconAnimation")
    }
}
