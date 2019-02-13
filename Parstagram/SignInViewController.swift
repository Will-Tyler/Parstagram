//
//  SignInViewController.swift
//  Kleene
//
//  Created by Will Tyler on 2/6/19.
//  Copyright © 2019 Kleene. All rights reserved.
//

import UIKit


class SignInViewController: UIViewController, UITextFieldDelegate {

	convenience init(delegate: SignInViewControllerDelegate? = nil) {
		self.init(nibName: nil, bundle: nil)
		self.delegate = delegate
	}
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		title = "Sign In"
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	private lazy var segmentedControl: UISegmentedControl = {
		let items = ["Sign In", "Register"]
		let control = UISegmentedControl(items: items)

		control.selectedSegmentIndex = 0
		control.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        control.accessibilityIdentifier = "Sign-in Toggle"

		return control
	}()
	private lazy var fieldContainer: UIView = {
		let view = UIView()

		view.backgroundColor = .white
		view.layer.masksToBounds = false
		view.layer.cornerRadius = 5

		return view
	}()
	private lazy var emailField: UITextField = {
		let field = UITextField()

		field.delegate = self
		field.placeholder = "Email"
		field.keyboardType = .emailAddress

		return field
	}()
	private lazy var passwordField: UITextField = {
		let field = UITextField()

		field.delegate = self
		field.placeholder = "Password"
		field.isSecureTextEntry = true
		field.returnKeyType = .done

		return field
	}()
	private lazy var button: UIButton = {
		let button = UIButton()
		let segmentedControlColor = segmentedControl.tintColor!

		button.backgroundColor = .clear
		button.setAttributedTitle(buttonSignInTitle, for: .normal)
		button.setTitleColor(segmentedControlColor, for: .normal)

		button.layer.masksToBounds = false
		button.layer.cornerRadius = 4
		button.layer.borderWidth = 1
		button.layer.borderColor = segmentedControlColor.cgColor

		button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
		button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)

		return button
	}()
	private var fieldContainerCenterYConstraint: NSLayoutConstraint!

	private func setupInitialLayout() {
		fieldContainer.addSubview(emailField)
		fieldContainer.addSubview(passwordField)

		emailField.translatesAutoresizingMaskIntoConstraints = false
		emailField.leadingAnchor.constraint(equalTo: fieldContainer.leadingAnchor, constant: 16).isActive = true
		emailField.trailingAnchor.constraint(equalTo: fieldContainer.trailingAnchor).isActive = true
		emailField.topAnchor.constraint(equalTo: fieldContainer.topAnchor).isActive = true
		emailField.heightAnchor.constraint(equalTo: fieldContainer.heightAnchor, multiplier: 1/2).isActive = true

		passwordField.translatesAutoresizingMaskIntoConstraints = false
		passwordField.leadingAnchor.constraint(equalTo: fieldContainer.leadingAnchor, constant: 16).isActive = true
		passwordField.trailingAnchor.constraint(equalTo: fieldContainer.trailingAnchor).isActive = true
		passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor).isActive = true
		passwordField.heightAnchor.constraint(equalTo: fieldContainer.heightAnchor, multiplier: 1/2).isActive = true

		let safeArea = view.safeAreaLayoutGuide

		view.addSubview(fieldContainer)
		view.addSubview(button)
		view.addSubview(segmentedControl)

		fieldContainer.translatesAutoresizingMaskIntoConstraints = false
		fieldContainer.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
		fieldContainerCenterYConstraint = fieldContainer.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
		fieldContainerCenterYConstraint.isActive = true
		fieldContainer.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.9).isActive = true
		fieldContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true

		segmentedControl.translatesAutoresizingMaskIntoConstraints = false
		segmentedControl.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
		segmentedControl.widthAnchor.constraint(equalTo: fieldContainer.widthAnchor).isActive = true
		segmentedControl.heightAnchor.constraint(equalToConstant: 32).isActive = true
		segmentedControl.bottomAnchor.constraint(equalTo: fieldContainer.topAnchor, constant: -16).isActive = true

		button.translatesAutoresizingMaskIntoConstraints = false
		button.topAnchor.constraint(equalTo: fieldContainer.bottomAnchor, constant: 16).isActive = true
		button.leftAnchor.constraint(equalTo: fieldContainer.leftAnchor).isActive = true
		button.rightAnchor.constraint(equalTo: fieldContainer.rightAnchor).isActive = true
		button.heightAnchor.constraint(equalTo: segmentedControl.heightAnchor).isActive = true
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = Colors.background
		setupInitialLayout()

		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))

		view.addGestureRecognizer(tapRecognizer)

		NotificationCenter.default.addObserver(self, selector: #selector(keyboard(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = false
	}

	@objc
	private func endEditing() {
		view.endEditing(true)
	}

	@objc
	private func keyboard(_ notification: Notification) {
		if let userInfo = notification.userInfo {
			let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
			let viewHeight = view.frame.height
			let endHeightFromBottom = viewHeight - endFrame.origin.y

			guard endHeightFromBottom > 0 else {
				fieldContainerCenterYConstraint.constant = 0
				return
			}

			let endHeightFromTop = viewHeight - endHeightFromBottom
			let newOffset = viewHeight / 2 - endHeightFromTop / 2

			fieldContainerCenterYConstraint.constant = -newOffset
		}
	}

	var delegate: SignInViewControllerDelegate?
	private var mode: Mode {
		get {
			switch segmentedControl.selectedSegmentIndex {
			case 0:
				return .signIn

			case 1:
				return .register

			default: fatalError()
			}
		}
	}

	private var buttonIsPressed = false
	private lazy var segmentedControlColor = self.segmentedControl.tintColor!
	private lazy var buttonSignInTitle = NSAttributedString(string: "Sign In", attributes: [.foregroundColor: self.segmentedControlColor])
	private lazy var buttonRegisterTitle = NSAttributedString(string: "Register", attributes: [.foregroundColor: self.segmentedControlColor])

	private func toggleButtonColors() {
		buttonIsPressed.toggle()

		let segmentedControlColor = segmentedControl.tintColor!

		if buttonIsPressed {
			button.backgroundColor = segmentedControlColor

			let currentTitle = button.currentAttributedTitle!
			let newTitle = NSAttributedString(string: currentTitle.string, attributes: [.foregroundColor: Colors.background])

			button.setAttributedTitle(newTitle, for: .normal)
		}
		else {
			button.backgroundColor = .clear
			button.setAttributedTitle(mode == .signIn ? buttonSignInTitle : buttonRegisterTitle, for: .normal)
		}
	}
	@objc
	private func buttonPressed() {
		toggleButtonColors()
	}
	@objc
	private func buttonReleased() {
		toggleButtonColors()

		guard let email = emailField.text, let password = passwordField.text else {
			return
		}

		switch mode {
		case .signIn:
			delegate?.signIn(withEmail: email, password: password)

		case .register:
			delegate?.register(withEmail: email, password: password)
		}
	}

	@objc
	private func segmentedControlValueChanged() {
		switch mode {
		case .signIn:
			button.setAttributedTitle(buttonSignInTitle, for: .normal)

		case .register:
			button.setAttributedTitle(buttonRegisterTitle, for: .normal)
		}

		title = button.titleLabel?.text
	}

	// UITextField delegate
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField === emailField {
			passwordField.becomeFirstResponder()
		}
		else if textField === passwordField {
			guard let email = emailField.text, let password = passwordField.text else {
				return false
			}

			delegate?.signIn(withEmail: email, password: password)
		}
		else {
			fatalError()
		}

		return true
	}

}


fileprivate enum Mode {

	case signIn
	case register

}


protocol SignInViewControllerDelegate {

	func signIn(withEmail email: String, password: String)
	func register(withEmail email: String, password: String)

}
