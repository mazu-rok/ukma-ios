//
//  PostListViewController.swift
//  MazurokApp
//
//  Created by Andrii Mazurok on 15.02.2026.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var savedPostsButton: UIBarButtonItem!
    
    @IBOutlet weak var postsTableView: UITableView!
    private let cellReuseIdentifier = "PostCellID"
    
    private var posts: [Post] = [] {
        willSet(newPosts) {
            if posts.isEmpty {
                navigationItem.title = newPosts.first?.domain
            }
        }
    }
    
    private var savedLastPostID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postsTableView.delegate = self
        postsTableView.dataSource = self
        
        configureUI()
        fetchPosts()
    }
    
    private func configureUI() {
        postsTableView.rowHeight = 300
        postsTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        postsTableView.backgroundColor = .systemGroupedBackground
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? PostTableViewCell else {
            fatalError("The dequeued cell is not an instance of CustomTableViewCell.")
        }
        
        if indexPath.row == posts.count-1 && savedLastPostID != posts.last?.id {
            savedLastPostID = posts.last?.id
            fetchPosts(from: posts.last?.id)
        }
        
        let item = posts[indexPath.row]
        cell.configure(with: item)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPost = posts[indexPath.row]
        
        performSegue(withIdentifier: "presentPost", sender: selectedPost)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentPost" {
            if let postVC = segue.destination as? PostViewController, let post = sender as? Post {
               postVC.setPost(post)
            }
        }
    }
    
    private func fetchPosts(from lastPostID: String? = nil) {
        Task { [weak self] in
            do {
                let posts = try await ApiService.sharedInstance.getPosts(limit: 5, after: lastPostID)
                print(posts)
                
                self?.posts.append(contentsOf: posts)
                DispatchQueue.main.async {
                    self?.postsTableView.reloadData()
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
