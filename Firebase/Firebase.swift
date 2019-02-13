//
//  Firebase.swift
//  Parstagram
//
//  Created by Will Tyler on 2/12/19.
//  Copyright © 2019 Parstagram. All rights reserved.
//

import Firebase


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

}
