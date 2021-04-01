//
//  SignUpViewController.swift
//  RogueClient
//
//  Created by Antonio Campos on 4/1/21.
//  Copyright © 2021 IVPN. All rights reserved.
//

import UIKit
import JGProgressHUD
import Amplify

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
    
    private let hud = JGProgressHUD(style: .dark)
    var isSigningUp: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "signUpScreen"
        navigationController?.navigationBar.prefersLargeTitles = false
        emailTextField.becomeFirstResponder()
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
        guard !isSigningUp else { return }
        
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
        
        isSigningUp = true

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
    
    private func goToSignUpConfirm() -> Void {
        self.isSigningUp = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.performSegue(withIdentifier: "SignUpConfirm", sender: self)
        }
    }
    
    private func signUpSucces() -> Void {
        self.isSigningUp = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func signUpError(error: AuthError) {
        self.isSigningUp = false
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignUpConfirm" {
            if let destinationVC = segue.destination as? SignUpConfirmViewController {
                destinationVC.signUpUsername = (emailTextField.text ?? "").trim()
                destinationVC.signUpPassword = getPasswordNonSecure()
            }
        }
    }
    
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


