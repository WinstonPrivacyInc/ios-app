//
//  ForgotPasswordViewController.swift
//  RogueClient
//
//  Created by Antonio Campos on 3/11/21.
//  Copyright © 2021 Winston Privacy. All rights reserved.
//

import Foundation
import UIKit
import JGProgressHUD
import Amplify

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    private var isRequestingReset = false
    private let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "forgotPasswordScreen"
        navigationController?.navigationBar.prefersLargeTitles = false
        initNavigationBar()
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
    
    private func initNavigationBar() {
        if isPresentedModally {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissViewController(_:)))
        }
    }

    @IBAction func passwordReset(_ sender: Any) {
        
        guard !isRequestingReset else { return }
        
        isRequestingReset = true
        let email = (self.emailTextField.text ?? "").trim()
        
        guard ServiceStatus.isValidEmail(email: email) else {
            isRequestingReset = false
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Requesting password reset..."
        hud.show(in: (navigationController?.view)!)
        
        
        Amplify.Auth.resetPassword(for: email) { (result) in
            do {
                let resetResult = try result.get()
                switch resetResult.nextStep {
                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                    print("Confirm reset password with code send to - \(deliveryDetails) \(String(describing: info))")
                case .done:
                    print("Reset completed")
                }
            } catch {
                print("Reset password failed with error \(error)")
            }
        }
        /**
         guard !loginProcessStarted else { return }
         
         let username = (self.emailTextField.text ?? "").trim()
         let password = (self.passwordTextField.text ?? "").trim()
         
         loginProcessStarted = true
         
         guard ServiceStatus.isValidEmail(email: username) else {
             loginProcessStarted = false
             showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
             return
         }
         
         guard ServiceStatus.isValidPassword(password: password) else {
             loginProcessStarted = false
             showAlert(title: "Invalid Password", message: "Please enter your password.")
             return
         }
         
         hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
         hud.detailTextLabel.text = "Signin in..."
         hud.show(in: (navigationController?.view)!)
         
         Amplify.Auth.signIn(username: username, password: password) { result in
            switch result {
                case .success:
                     DispatchQueue.main.async {
                         self.signInSuccess()
                     }
                case .failure(let error):
                     DispatchQueue.main.async {
                         self.signInFailure(authError: error)
                     }
                }
            }
         */
        
        
        
    }
}
