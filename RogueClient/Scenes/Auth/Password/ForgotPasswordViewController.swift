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
import KAPinField

class ForgotPasswordViewController: UIViewController {
    
    enum ViewMode {
        case requestPasswordReset
        case confirmNewPassword
    }
    
    var currentMode: ViewMode = ViewMode.requestPasswordReset
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var keyboardView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var confirmationCodeField: KAPinField!
    @IBOutlet weak var hiddenConfirmationCodeField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    private var isCognitoOperationInProgress = false
    private let hud = JGProgressHUD(style: .dark)
    private var passwordResetUsername: String = ""
    private var passwordResetConfirmationCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "forgotPasswordScreen"
        navigationController?.navigationBar.prefersLargeTitles = false

        hiddenConfirmationCodeField.inputAccessoryView = keyboardView
        confirmationCodeField.properties.delegate = self
        confirmationCodeField.properties.numberOfCharacters = 6
        confirmationCodeField.properties.isSecure = false
        confirmationCodeField.properties.animateFocus = true
        
        // mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.dismissKeyboard)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861 Remove when fixed in future releases
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
    @IBAction func confirmationCodeChanged(_ textField: UITextField) {
        // bug in library, must set token property first in order for text to be set
        confirmationCodeField.properties.token = confirmationCodeField.properties.token
        confirmationCodeField.text = textField.text
    }
    
    @IBAction func actionButtonClicked(_ sender: Any) {
        if currentMode == ViewMode.requestPasswordReset {
            requestPasswordReset()
        } else if currentMode == ViewMode.confirmNewPassword {
            print("verify if code is valid...")
            confirmPasswordReset(confirmationCode: self.passwordResetConfirmationCode)
        }
    }
    
    private func requestPasswordReset() {
        guard !isCognitoOperationInProgress else { return }
        
        isCognitoOperationInProgress = true
        let email = (self.inputTextField.text ?? "").trim()
        
        guard ServiceStatus.isValidEmail(email: email) else {
            isCognitoOperationInProgress = false
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        
        showIndicator(message: "Requesting password reset...")
        
        inputTextField.resignFirstResponder()
        
        passwordResetUsername = email
        
        Amplify.Auth.resetPassword(for: email) { result in
            do {
                let resetResult = try result.get()
                switch resetResult.nextStep {
             
                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                    print("Confirm reset password with code send to - \(deliveryDetails) \(String(describing: info))")
                    self.passwordResetRequestSuccess()
                case .done:
                    print("Reset completed")
                }
            } catch (let error) {
                print("Password reset failure \(error)")
                self.passwordResetRequestFailure(error: error)
            }
        }
    }
    
    private func showIndicator(message: String) -> Void {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = message
        hud.show(in: (navigationController?.view)!)
    }
    
    private func confirmPasswordReset(confirmationCode: String) -> Void {
        guard !isCognitoOperationInProgress else { return }
        
        guard ServiceStatus.isValidConfirmationCode(confirmationCode: confirmationCode) else {
            showAlert(title: "Error", message: "Invalid confirmation code")
            return
        }
        
        inputTextField.isSecureTextEntry = false
        let newPassword = (inputTextField.text ?? "").trim()
        inputTextField.isSecureTextEntry = true
        
        guard ServiceStatus.isValidPassword(password: newPassword) else {
            isCognitoOperationInProgress = false
            showAlert(title: "Invalid Password", message: "Please enter your password.")
            return
        }
        
        isCognitoOperationInProgress = true
        showIndicator(message: "Resetting your password...")
        

        Amplify.Auth.confirmResetPassword(for: passwordResetUsername, with: newPassword, confirmationCode: confirmationCode) { result in
            switch result {
            case .success:
                log(info: "Password reset confirm success")
                self.passwordResetConfirmSuccess()
            case .failure(let error):
                log(error: "Password reset confirm error \(error.errorDescription)")
                self.passwordResetConfirmFailure(error: error)
            }
        }
    }
    
    private func switchToConfirmMode() {
        self.currentMode = ViewMode.confirmNewPassword
        
        self.messageLabel.text = "Enter your new password"
        
        self.inputTextField.text = ""
        self.inputTextField.placeholder = "New Password"
        self.inputTextField.keyboardType = .default
        self.inputTextField.isSecureTextEntry = true
        self.inputTextField.textContentType = .password
        self.inputTextField.becomeFirstResponder()
        
        self.actionButton.setTitle("Reset Password", for: .normal)
    }
    
    private func passwordResetRequestSuccess() -> Void {
        self.isCognitoOperationInProgress = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.hiddenConfirmationCodeField.becomeFirstResponder()
        }
    }
    
    private func passwordResetConfirmSuccess() -> Void {
        self.isCognitoOperationInProgress = false
        
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.navigationController?.popViewController(animated: true)
            let data = ["email": self.passwordResetUsername]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name.PasswordResetSuccess.rawValue), object: nil, userInfo: data)
        }
    }
    
    private func passwordResetConfirmFailure(error: AuthError) -> Void {
        self.isCognitoOperationInProgress = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            
            let isInvalidConfirmationCode = error.errorDescription.range(of: "invalid verification code", options: .caseInsensitive) != nil
            if isInvalidConfirmationCode {
                self.hiddenConfirmationCodeField.becomeFirstResponder()
            }
            
            // has to be last otherwise it will hide the keyboard on dismiss
            self.showAlert(title: "Error", message: error.errorDescription)
        }
    }
    
    private func passwordResetRequestFailure(error: Error) -> Void {
        self.isCognitoOperationInProgress = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.showAlert(title: "Reset failed", message: "There was an error verifying the reset code.\(error)")
        }
    }
    
    
}

extension ForgotPasswordViewController : KAPinFieldDelegate {
  func pinField(_ field: KAPinField, didFinishWith code: String) {
    self.passwordResetConfirmationCode = code
    self.switchToConfirmMode()
  }
}
