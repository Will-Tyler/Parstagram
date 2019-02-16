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

	static func observeFeed(with handler: @escaping ([Post]?, Error?)->()) {
		if let currentUser = Auth.auth().currentUser {
			let db = Firestore.firestore()

			db.collection("users").document(currentUser.uid).collection("posts").order(by: "date", descending: true).addSnapshotListener({ (snapshot, error) in
				if let error = error {
					handler(nil, error)
				}
				else if let changes = snapshot?.documentChanges {
					let additions = changes.filter({ $0.type == .added })
					let posts = additions.map({ (change: DocumentChange) -> Post in
						let doc = change.document
						let id = doc.documentID
						let data = doc.data()
						let authorID = data["authorID"] as! String
						let caption = data["caption"] as! String
						let date = (data["date"] as! Timestamp).dateValue()

						return Post(id: id, caption: caption, authorID: authorID, date: date, pngData: nil)
					})

					handler(posts, nil)
				}
			})
		}
	}

}
