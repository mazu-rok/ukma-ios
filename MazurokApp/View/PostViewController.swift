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
    private var bookmarkLayer: CAShapeLayer!
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bookmarkLayer?.position = CGPoint(x: image.bounds.midX,
                                          y: image.bounds.midY)
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
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        image.addGestureRecognizer(doubleTap)
        image.isUserInteractionEnabled = true
        
        bookmarkLayer = createBookmarkLayer(in: image)
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
        
        shapeLayer.bounds = path.bounds
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
