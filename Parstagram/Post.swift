//
//  Post.swift
//  Parstagram
//
//  Created by Will Tyler on 2/13/19.
//  Copyright © 2019 Parstagram. All rights reserved.
//

import Foundation


struct Post {

	let id: String
	let caption: String
	let authorID: String
	let date: Date
	var pngData: Data?

	func handlePNGData(with handler: @escaping (Data?, Error?)->()) {
		if let data = pngData {
			handler(data, nil)
		}
		else {
			Firebase.handlePNGData(for: self, with: handler)
		}
	}

}
