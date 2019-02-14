//
//  Firebase.swift
//  Parstagram
//
//  Created by Will Tyler on 2/12/19.
//  Copyright © 2019 Parstagram. All rights reserved.
//

import Firebase
import FirebaseFirestore


class Firebase {

	static func configure() {
		FirebaseApp.configure()
	}

	static var isSignedIn: Bool {
		get {
			return Auth.auth().currentUser != nil
		}
	}

	static func signIn(withEmail email: String, password: String, completion: AuthDataResultCallback? = nil) {
		Auth.auth().signIn(withEmail: email, password: password, completion: completion)
	}

	static func register(withEmail email: String, password: String, completion: AuthDataResultCallback? = nil) {
		Auth.auth().createUser(withEmail: email, password: password, completion: completion)
	}

	static func signOut(completion: ((Error?)->())? = nil) {
		var _error: Error? = nil

		do {
			try Auth.auth().signOut()
		}
		catch {
			_error = error
		}

		completion?(_error)
	}

	static func add(post: Post, completion: ((Error?)->())? = nil) {
		if let currentUser = Auth.auth().currentUser {
			let db = Firestore.firestore()
			let dataDictionary: [String: Any] = [
				"caption": post.caption,
				"date": Date()
			]

			let document = db.collection("users").document(currentUser.uid).collection("posts").document()
			let id = document.documentID

			document.setData(dataDictionary, completion: { error in
				if let error = error {
					completion?(error)
				}
				else {
					let storage = Storage.storage().reference(withPath: "users/\(currentUser.uid)/\(id).png")
					let metadata = StorageMetadata()

					metadata.contentType = "image/png"

					storage.putData(post.pngData, metadata: metadata, completion: { (metadata, error) in
						completion?(error)
					})
				}
			})
		}
	}

}
