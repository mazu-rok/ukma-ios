//
//  PostListViewController.swift
//  MazurokApp
//
//  Created by Andrii Mazurok on 15.02.2026.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var savedPostsButton: UIBarButtonItem!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var postsTableView: UITableView!
    private let cellReuseIdentifier = "PostCellID"
    
    private var posts: [Post] = [] {
        willSet(newPosts) {
            if posts.isEmpty {
                navigationItem.title = newPosts.first?.domain
            }
        }
    }
    
    private var savedPosts: [Post] = []
    
    private var savedLastPostID: String?
    
    private var savedPostsDisplayingMode: Bool = false {
        didSet {
            searchBar.isHidden = !savedPostsDisplayingMode
            searchBarHeight.constant = savedPostsDisplayingMode ? 64 : 0
        }
    }

    var filteredPosts: [Post] = []
    
    var isSearching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        postsTableView.delegate = self
        postsTableView.dataSource = self
        searchBar.delegate = self
        
        configureUI()
        savedPosts = StorageManager.sharedInstance.loadPosts()
        fetchPosts()
    }
    
    private func configureUI() {
        postsTableView.rowHeight = 300
        postsTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        postsTableView.backgroundColor = .systemGroupedBackground
    }
    
    private func getPostsForDisplay() -> [Post] {
        if savedPostsDisplayingMode {
            return isSearching ? filteredPosts : savedPosts
        } else {
            return posts
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getPostsForDisplay().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? PostTableViewCell else {
            fatalError("The dequeued cell is not an instance of CustomTableViewCell.")
        }
        
        if !savedPostsDisplayingMode && indexPath.row == posts.count-1 && savedLastPostID != posts.last?.id {
            savedLastPostID = posts.last?.id
            fetchPosts(from: posts.last?.id)
        }
        
        var post = getPostsForDisplay()[indexPath.row]
        cell.configure(with: post,
                       onShareButtonTapped: {
            self.presentShareSheet(for: post)
        }, onSaveButtonTapped: { saved in
            if let index = self.posts.firstIndex(of: post) {
                self.posts[index].saved = saved
            }
            if saved {
                post.saved = true
                self.savedPosts.append(post)
            } else {
                self.savedPosts.remove(at: self.savedPosts.firstIndex(of: post)!)
            }
            self.postsTableView.reloadData()
            StorageManager.sharedInstance.savePosts(self.savedPosts)
        })

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPostIndex = indexPath.row
        
        performSegue(withIdentifier: "presentPost", sender: selectedPostIndex)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentPost" {
            if let postVC = segue.destination as? PostViewController, let postIndex = sender as? Int {
                var post = getPostsForDisplay()[postIndex]
                postVC.setPost(post,
                               onShareButtonTapped: {
                    self.presentShareSheet(for: post)
                }, onSaveButtonTapped: { saved in
                    if let index = self.savedPostsDisplayingMode ? self.posts.firstIndex(of: post) : postIndex {
                        self.posts[index].saved = saved
                    }
                    if saved {
                        post.saved = true
                        self.savedPosts.append(post)
                    } else {
                        self.savedPosts.remove(at: self.savedPosts.firstIndex(of: post)!)
                    }
                    self.postsTableView.reloadData()
                    StorageManager.sharedInstance.savePosts(self.savedPosts)
                })
            }
        }
    }
    
    private func fetchPosts(from lastPostID: String? = nil) {
        Task {
            do {
                var posts = try await ApiService.sharedInstance.getPosts(limit: 5, after: lastPostID)
                print(posts)
                
                for index in posts.indices {
                    if self.savedPosts.contains(posts[index]) {
                        posts[index].saved = true
                    }
                }
                
                self.posts.append(contentsOf: posts)
                DispatchQueue.main.async {
                    self.postsTableView.reloadData()
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func presentShareSheet(for post: Post) {
        let url = URL(string: "http://localhost:8080/posts/\(post.id)")!
        
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = self.view
        }
        
        present(activityViewController, animated: true)
    }
    
    @IBAction func showSavedPostsButtonTapped(_ sender: Any) {
        savedPostsDisplayingMode.toggle()
        savedPostsButton.image = UIImage(systemName: savedPostsDisplayingMode ? "bookmark.fill" : "bookmark")
        
        postsTableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredPosts = []
        } else {
            isSearching = true
            filteredPosts = savedPosts.filter { post in
                post.title.lowercased().contains(searchText.lowercased())
            }
        }
        postsTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        postsTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
