//
//  SignUpViewController.swift
//  RogueClient
//
//  Created by Antonio Campos on 4/1/21.
//  Copyright © 2021 Winston Privacy. All rights reserved.
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
        navigationController?.navigationBar.prefersLargeTitles = false
        emailTextField.becomeFirstResponder()
        
        hiddenConfirmationCodeField.inputAccessoryView = keyboardView
        confirmationCodeField.properties.delegate = self
        confirmationCodeField.properties.numberOfCharacters = 6
        confirmationCodeField.properties.isSecure = false
        confirmationCodeField.properties.animateFocus = true
//
//        addObservers()
//        hideKeyboardOnTap()
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

        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Signin up..."
        hud.show(in: (navigationController?.view)!)
        
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        
        Amplify.Auth.signUp(username: email, password: password, options: options) { result in
                switch result {
                case .success(let signUpResult):
                    if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                        print("Delivery details \(String(describing: deliveryDetails))")
                        self.goToSignUpConfirm()
                    } else {
                        print("SignUp Complete")
                        self.signUpSucces()
                    }
                case .failure(let error):
                    print("An error occurred while registering a user \(error)")
                    self.signUpError(error: error)
                }
            }
    }
    
    func confirmSignUp(_ sender: Any) {
        guard !isCognitoOperationInProgress else { return }
        
        isCognitoOperationInProgress = true
        
        let confirmationCode = (self.confirmationCodeField.text ?? "").trim()
        
        guard !confirmationCode.isEmpty else {
            showAlert(title: "Invalid Code", message: "Please enter a valid confirmation code.")
            isCognitoOperationInProgress = false
            return
        }
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Confirming your email..."
        hud.show(in: (navigationController?.view)!)
        
        let signUpUsername = ""
        Amplify.Auth.confirmSignUp(for: signUpUsername, confirmationCode: confirmationCode) { result in
                switch result {
                case .success:
                    self.emailConfirmSuccess()
                case .failure(let error):
                    self.emailConfirmFailure(error: error)
                }
        }
    }
    
    private func emailConfirmSuccess() -> Void {
        
    }
    
    private func emailConfirmFailure(error: AuthError) -> Void {
        
    }
    
    private func goToSignUpConfirm() -> Void {
        self.isCognitoOperationInProgress = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            // self.performSegue(withIdentifier: "SignUpConfirm", sender: self)
            self.hiddenConfirmationCodeField.becomeFirstResponder()
        }
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "SignUpConfirm" {
//            if let destinationVC = segue.destination as? SignUpConfirmViewController {
//                destinationVC.signUpUsername = (emailTextField.text ?? "").trim()
//                destinationVC.signUpPassword = getPasswordNonSecure()
//            }
//        }
//    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            emailTextField.resignFirstResponder()
            // startSignInProcess()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
}


extension SignUpViewController : KAPinFieldDelegate {
  func pinField(_ field: KAPinField, didFinishWith code: String) {
    print("didFinishWith : \(code)")
    // self.confirmEmailChange(confirmationCode: code)
  }
}

