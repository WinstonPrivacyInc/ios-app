//
//  SignUpViewController.swift
//  RogueClient
//
//  Created by Antonio Campos on 4/1/21.
//  Copyright © 2021 Winston Privacy, Inc. All rights reserved.
//

import UIKit
import JGProgressHUD
import Amplify
import KAPinField

class SignUpViewController: UIViewController {
 
    
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
    
    @IBOutlet var keyboardView: UIView!
    @IBOutlet weak var hiddenConfirmationCodeField: UITextField!
    
    @IBOutlet weak var confirmationCodeField: KAPinField!
    private let hud = JGProgressHUD(style: .dark)
    var isCognitoOperationInProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "signUpScreen"
        emailTextField.becomeFirstResponder()
        
        hiddenConfirmationCodeField.inputAccessoryView = keyboardView
        confirmationCodeField.properties.delegate = self
        confirmationCodeField.properties.numberOfCharacters = 6
        confirmationCodeField.properties.isSecure = false
        confirmationCodeField.properties.animateFocus = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861
        // Remove when fixed in future releases
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
    @IBAction func dimissView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmationCodeUpdated(_ textField: UITextField) {
        // bug in library, must set token property first in order for text to be set
        confirmationCodeField.properties.token = confirmationCodeField.properties.token
        confirmationCodeField.text = textField.text
    }
    
    @IBAction func singUp(_ sender: Any) {
        guard !isCognitoOperationInProgress else { return }
        
        let email = (emailTextField.text ?? "").trim()
        guard ServiceStatus.isValidEmail(email: email) else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        
        let password = getPasswordNonSecure()
        
        guard ServiceStatus.isValidPassword(password: password) else {
            showAlert(title: "Invalid Password", message: "Please enter a valid password.")
            return
        }
        
        isCognitoOperationInProgress = true
        showIndicator(text: "Signin up...")
        
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        
        Amplify.Auth.signUp(username: email, password: password, options: options) { result in
                switch result {
                case .success(let signUpResult):
                    if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                        log(info: "Sign up success. Delivery details \(String(describing: deliveryDetails))")
                        self.showEmailConfirmationInputAndKeyboard()
                    } else {
                        log(info: "SignUp Complete")
                        self.signUpSucces()
                    }
                case .failure(let error):
                    log(error: "An error occurred while registering a user \(error)")
                    self.signUpError(error: error)
                }
            }
    }
    
    private func showEmailConfirmationInputAndKeyboard() -> Void {
        self.isCognitoOperationInProgress = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.hiddenConfirmationCodeField.becomeFirstResponder()
        }
    }
    
    private func emailConfirmFailure(error: AuthError) -> Void {
        
    }
    
    private func signUpSucces() -> Void {
        self.isCognitoOperationInProgress = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func signUpError(error: AuthError) {
        self.isCognitoOperationInProgress = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.showAlert(title: "Error", message: error.errorDescription)
        }
    }
    
    private func getPasswordNonSecure() -> String {
        // toggle is secured otherwise you cannot get the actual value
        passwordTextField.isSecureTextEntry = false
        let password = (passwordTextField.text ?? "").trim()
        passwordTextField.isSecureTextEntry = true
        
        return password
    }
    
    func confirmUserEmail(confirmationCode: String) {
        guard !isCognitoOperationInProgress else { return }
        
        isCognitoOperationInProgress = true

        guard ServiceStatus.isValidConfirmationCode(confirmationCode: confirmationCode) else {
            showAlert(title: "Invalid Code", message: "Please enter a valid confirmation code.")
            isCognitoOperationInProgress = false
            return
        }
        
        showIndicator(text: "Confirming your email...")
        
        let email = (emailTextField.text ?? "").trim()
        let password = getPasswordNonSecure()
        
        Amplify.Auth.confirmSignUp(for: email, confirmationCode: confirmationCode) { result in
                switch result {
                case .success:
                    self.emailConfirmSuccess(email: email, password: password)
                case .failure(let error):
                    self.emailConfirmFailure(error: error)
                }
        }
    }
    
    func emailConfirmSuccess(email: String, password: String) -> Void {
        self.isCognitoOperationInProgress = false
        
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.dismissViewController(self)
            
            let data = ["email": email, "password": password]
            NotificationCenter.default.post(name: Notification.Name.EmailConfirmationSuccess, object: nil, userInfo: data)
        }
    }
    
    func showIndicator(text: String) -> Void {
        DispatchQueue.main.async {
            self.hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
            self.hud.detailTextLabel.text = text
            self.hud.show(in: (self.navigationController?.view)!)
        }
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            singUp(self)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
}


extension SignUpViewController : KAPinFieldDelegate {
  func pinField(_ field: KAPinField, didFinishWith code: String) {
     self.confirmUserEmail(confirmationCode: code)
  }
}

