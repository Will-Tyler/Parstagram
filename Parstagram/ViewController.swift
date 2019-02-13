//
//  ViewController.swift
//  Parstagram
//
//  Created by Will Tyler on 2/13/19.
//  Copyright © 2019 Parstagram. All rights reserved.
//

import UIKit


class ViewController: UIViewController, SignInViewControllerDelegate {

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		title = "Parstagram"
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private lazy var signInViewController = SignInViewController(delegate: self)

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = Colors.background
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

}
