//
//  PostTableViewCell.swift
//  Parstagram
//
//  Created by Will Tyler on 2/14/19.
//  Copyright © 2019 Parstagram. All rights reserved.
//

import UIKit


class PostTableViewCell: UITableViewCell {

	private lazy var postImageView: UIImageView = {
		let image = UIImageView()

		image.clipsToBounds = true
		image.contentMode = .scaleAspectFit

		return image
	}()
	private lazy var authorLabel: UILabel = {
		let label = UILabel()

		label.numberOfLines = 1
		label.textColor = .white
		label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)

		return label
	}()
	private lazy var captionLabel: UILabel = {
		let label = UILabel()

		label.numberOfLines = 0
		label.textColor = .white

		return label
	}()

	override func layoutSubviews() {
		super.layoutSubviews()

		backgroundColor = .clear
	}

	private func setupInitialLayout() {
		let headerView = UIView()

		headerView.addSubview(authorLabel)

		authorLabel.translatesAutoresizingMaskIntoConstraints = false
		authorLabel.heightAnchor.constraint(equalToConstant: authorLabel.intrinsicContentSize.height).isActive = true
		authorLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
		authorLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
		authorLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true

		addSubview(headerView)
		addSubview(postImageView)
		addSubview(captionLabel)

		headerView.translatesAutoresizingMaskIntoConstraints = false
		headerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		headerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		headerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		headerView.heightAnchor.constraint(equalToConstant: 64).isActive = true

		postImageView.translatesAutoresizingMaskIntoConstraints = false
		postImageView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
		postImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		postImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		postImageView.heightAnchor.constraint(equalTo: widthAnchor).isActive = true

		captionLabel.translatesAutoresizingMaskIntoConstraints = false
		captionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 8).isActive = true
		captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
		captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

		bottomAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 8).isActive = true
	}

	private var didSetupInitialLayout = false
	var post: Post! {
		didSet {
			authorLabel.text = "will@gmail.com"
			captionLabel.text = post.caption
			post.handlePNGData(with: { (data, error) in
				if let data = data {
					let image = UIImage(data: data)

					self.postImageView.image = image
				}
			})

			if !didSetupInitialLayout {
				setupInitialLayout()
				didSetupInitialLayout = true
			}
		}
	}

}
