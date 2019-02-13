//
//  PostViewController.swift
//  Parstagram
//
//  Created by Will Tyler on 2/13/19.
//  Copyright © 2019 Parstagram. All rights reserved.
//

import UIKit
import AlamofireImage


class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	private lazy var imageView: UIImageView = {
		let view = UIImageView()

		view.clipsToBounds = true
		view.contentMode = .scaleAspectFill
		view.backgroundColor = .lightGray
		view.isUserInteractionEnabled = true

		view.layer.masksToBounds = false
		view.layer.cornerRadius = 4

		let tap = UITapGestureRecognizer(target: self, action: #selector(imageViewTappedAction))

		view.addGestureRecognizer(tap)

		return view
	}()
	private lazy var textField: UITextField = {
		let field = UITextField()

		field.contentVerticalAlignment = .top
		field.attributedPlaceholder = NSAttributedString(string: "Enter a caption here.", attributes: [.foregroundColor: UIColor.lightText])
		field.textColor = .white

		return field
	}()
	private lazy var postButton: UIButton = {
		let button = UIButton()

		button.backgroundColor = button.tintColor
		button.setTitle("Post", for: .normal)
		button.addTarget(self, action: #selector(postButtonAction), for: .touchUpInside)

		button.layer.masksToBounds = false
		button.layer.cornerRadius = 4

		return button
	}()

	private func setupInitialLayout() {
		view.addSubview(imageView)
		view.addSubview(postButton)
		view.addSubview(textField)

		let safeArea = view.safeAreaLayoutGuide

		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8).isActive = true
		imageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8).isActive = true
		imageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8).isActive = true
		imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true

		postButton.translatesAutoresizingMaskIntoConstraints = false
		postButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
		postButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
		postButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8).isActive = true
		postButton.heightAnchor.constraint(equalToConstant: postButton.intrinsicContentSize.height).isActive = true

		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
		textField.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
		textField.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
		textField.bottomAnchor.constraint(equalTo: postButton.bottomAnchor, constant: -8).isActive = true
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = Colors.background
		setupInitialLayout()
	}

	@objc
	private func imageViewTappedAction() {
		let picker = UIImagePickerController()

		picker.delegate = self
		picker.allowsEditing = true

		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			picker.sourceType = .camera
		}
		else {
			picker.sourceType = .photoLibrary
		}

		present(picker, animated: true)
	}

	@objc
	private func postButtonAction() {
	}

	// UIImagePickerControllerDelegate
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let image = info[.editedImage] as? UIImage {
			let desiredSize = CGSize(width: 300, height: 300)
			let scaledImage = image.af_imageScaled(to: desiredSize)

			imageView.image = scaledImage
			dismiss(animated: true)
		}
	}

}
