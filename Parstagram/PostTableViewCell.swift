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
		addSubview(postImageView)
		addSubview(authorLabel)
		addSubview(captionLabel)

		postImageView.translatesAutoresizingMaskIntoConstraints = false
		postImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		postImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		postImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		postImageView.heightAnchor.constraint(equalTo: widthAnchor).isActive = true

		authorLabel.translatesAutoresizingMaskIntoConstraints = false
		authorLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor).isActive = true
		authorLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		authorLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		authorLabel.heightAnchor.constraint(equalToConstant: authorLabel.intrinsicContentSize.height).isActive = true

		captionLabel.translatesAutoresizingMaskIntoConstraints = false
		captionLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor).isActive = true
		captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

		bottomAnchor.constraint(equalTo: captionLabel.bottomAnchor).isActive = true
	}

	private var didSetupInitialLayout = false
	var post: Post! {
		didSet {
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
