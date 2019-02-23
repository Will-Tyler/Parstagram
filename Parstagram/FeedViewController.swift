//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Will Tyler on 2/13/19.
//  Copyright © 2019 Parstagram. All rights reserved.
//

import UIKit
import Firebase
import MessageInputBar


class FeedViewController: UIViewController, SignInViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		title = "Parstagram"
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	private lazy var tableView: UITableView = {
		let table = UITableView()

		table.backgroundColor = .clear
		table.keyboardDismissMode = .interactive
		table.delegate = self
		table.dataSource = self
		table.tableFooterView = UIView(frame: .zero)
		table.register(PostTableViewCell.self, forCellReuseIdentifier: "PostTableViewCell")
		table.register(CommentTableViewCell.self, forCellReuseIdentifier: "CommentTableViewCell")
		table.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")

		return table
	}()
	private lazy var messageInputBar: MessageInputBar = {
		let input = MessageInputBar()

		input.inputTextView.placeholder = "Add a comment..."
		input.sendButton.setTitle("Post", for: .normal)
		input.delegate = self

		return input
	}()
	private lazy var signInViewController = SignInViewController(delegate: self)

	private func setupInitialLayout() {
		view.addSubview(tableView)

		let safeArea = view.safeAreaLayoutGuide

		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
		tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
		tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = Colors.background
		setupInitialLayout()

		let signOutItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOutItemAction))
		let postItem = UIBarButtonItem(image: UIImage(named: "add_box"), style: .plain, target: self, action: #selector(postItemAction))

		navigationItem.setLeftBarButton(signOutItem, animated: false)
		navigationItem.setRightBarButton(postItem, animated: false)

		observeFeed()

		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if !Firebase.isSignedIn {
			present(signInViewController, animated: false)
		}
	}

	private var showMessageInputBar = false
	override var inputAccessoryView: UIView? {
		return messageInputBar
	}
	override var canBecomeFirstResponder: Bool {
		return showMessageInputBar
	}

	@objc
	private func keyboardWillHide(_ notification: Notification) {
		messageInputBar.inputTextView.text = nil
		showMessageInputBar = false
		becomeFirstResponder()
	}

	// SignInViewControllerDelegate
	func signIn(withEmail email: String, password: String) {
		Firebase.signIn(withEmail: email, password: password, completion: { (authDataResult, error) in
			if let error = error {
				self.signInViewController.alertUser(title: "Error Signing In", message: error.localizedDescription)
			}
			else {
				self.dismiss(animated: true)
			}
		})
	}
	func register(withEmail email: String, password: String) {
		Firebase.register(withEmail: email, password: password, completion: { (authDataResult, error) in
			if let error = error {
				self.signInViewController.alertUser(title: "Error Registering", message: error.localizedDescription)
			}
			else {
				self.dismiss(animated: true)
			}
		})
	}

	@objc
	private func signOutItemAction() {
		Firebase.signOut(completion: { error in
			if let error = error {
				self.alertUser(title: "Error Signing Out", message: error.localizedDescription)
			}
			else {
				self.present(self.signInViewController, animated: true)
			}
		})
	}

	@objc
	private func postItemAction() {
		present(PostViewController(), animated: true)
	}

	private func observeFeed() {
		Firebase.observeFeed(with: { (posts, error) in
			if let error = error {
				self.alertUser(title: "Error", message: error.localizedDescription)
			}
			else if let posts = posts {
				self.posts.insert(contentsOf: posts, at: 0)
				self.tableView.reloadData()
			}
		})
	}

	private var posts = [Post]()
	private var lastSelectedPost: Post?

	// tableView
	private func isSelectable(_ path: IndexPath) -> IndexPath? {
		return path.row != 0 ? path : nil
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return posts.count
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1 + (posts[section].comments?.count ?? 0) + 1
	}
	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return isSelectable(indexPath) != nil
	}
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		return isSelectable(indexPath)
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		lastSelectedPost = posts[indexPath.section]
		
		showMessageInputBar = true
		becomeFirstResponder()
		messageInputBar.inputTextView.becomeFirstResponder()
		tableView.deselectRow(at: indexPath, animated: true)
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var post = posts[indexPath.section]

		post.didSetComments = {
			tableView.reloadData()
		}

		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell

			cell.post = post

			return cell
		}
		else if indexPath.row < (post.comments?.count ?? 0) + 1 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
			let comment = post.comments![indexPath.row-1]

			cell.backgroundColor = .clear
			cell.textLabel?.text = comment.content
			cell.textLabel?.textColor = .white

			return cell
		}
		else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)

			cell.backgroundColor = .clear
			cell.textLabel?.text = "Add a comment..."
			cell.textLabel?.textColor = .white

			return cell
		}
	}

	func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
		let content = text
		let authorID = Auth.auth().currentUser!.uid
		let comment = Comment(authorID: authorID, content: content)

		lastSelectedPost?.post(comment: comment)

		messageInputBar.inputTextView.text = nil
		showMessageInputBar = false
		becomeFirstResponder()
		inputBar.inputTextView.resignFirstResponder()
	}

}
