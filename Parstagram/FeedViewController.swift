//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Will Tyler on 2/13/19.
//  Copyright © 2019 Parstagram. All rights reserved.
//

import UIKit
import Firebase


class FeedViewController: UIViewController, SignInViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		title = "Parstagram"
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private lazy var tableView: UITableView = {
		let table = UITableView()

		table.backgroundColor = .clear
		table.allowsSelection = false
		table.delegate = self
		table.dataSource = self
		table.tableFooterView = UIView(frame: .zero)
		table.register(PostTableViewCell.self, forCellReuseIdentifier: "PostTableViewCell")

		return table
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

		postItem.tintColor = .white

		navigationItem.setLeftBarButton(signOutItem, animated: false)
		navigationItem.setRightBarButton(postItem, animated: false)

		observePosts()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if !Firebase.isSignedIn {
			present(signInViewController, animated: false)
		}
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

	private func observePosts() {
	}

	private var posts = [Post]()

	// tableView
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return posts.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell

		cell.post = posts[indexPath.row]

		return cell
	}

}
