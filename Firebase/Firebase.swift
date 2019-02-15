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

	@discardableResult
	static func post(pngData: Data, caption: String = "", completion: ((Error?)->())? = nil) -> Post {
		let authorID = Auth.auth().currentUser!.uid
		let db = Firestore.firestore()
		let document = db.collection("users").document(authorID).collection("posts").document()
		let id = document.documentID
		let post = Post(id: id, caption: caption, authorID: authorID, date: Date(), pngData: pngData)
		let dataDictionary: [String: Any] = [
			"caption": post.caption,
			"date": post.date,
			"authorID": post.authorID
		]

		document.setData(dataDictionary, completion: { error in
			if let error = error {
				completion?(error)
			}
			else {
				let storage = Storage.storage().reference(withPath: "users/\(authorID)/\(id).png")
				let metadata = StorageMetadata()

				metadata.contentType = "image/png"

				storage.putData(pngData, metadata: metadata, completion: { (metadata, error) in
					completion?(error)
				})
			}
		})

		return post
	}

	static func handlePNGData(for post: Post, with handler: @escaping (Data?, Error?)->()) {
		Storage.storage().reference(withPath: "users/\(Auth.auth().currentUser!.uid)/\(post.id).png").getData(maxSize: .max, completion: { (data, error) in
			handler(data, error)
		})
	}

}
