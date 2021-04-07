//
//  ChangeEmailViewController.swift
//  RogueClient
//
//  Created by Antonio Campos on 4/5/21.
//  Copyright © 2021 Winston Privacy. All rights reserved.
//

import UIKit
import SnapKit
import Foundation
import UIKit
import JGProgressHUD
import Amplify
import KAPinField

class ChangeEmailViewController: UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet var keyboardView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmationCodeField: KAPinField!
    @IBOutlet weak var hiddenConfirmationCodeField: UITextField!
    
    private var currentEmail = ""
    private var isCognitoOperationInProgress = false
    private let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "changeEmailScreen"
        
        DispatchQueue.main.async {
            self.currentEmail = KeyChain.username ?? ""
            self.emailTextField.text = self.currentEmail
        }

        hiddenConfirmationCodeField.inputAccessoryView = keyboardView
        hiddenConfirmationCodeField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        confirmationCodeField.properties.delegate = self
        confirmationCodeField.properties.numberOfCharacters = 6
        confirmationCodeField.properties.isSecure = false
        confirmationCodeField.properties.animateFocus = true
        
        mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.dismissKeyboard)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861 Remove when fixed in future releases
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // bug in library, must set token property first in order for text to be set
        confirmationCodeField.properties.token = confirmationCodeField.properties.token
        confirmationCodeField.text = textField.text
    }

    @IBAction func changeEmail(_ sender: Any) {
        guard !isCognitoOperationInProgress else { return }

        let email = (self.emailTextField.text ?? "").trim()
        
        guard email != self.currentEmail else {
            showAlert(title: "No Change", message: "Please enter a new email address.")
            return
        }

        guard ServiceStatus.isValidEmail(email: email) else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }

        emailTextField.resignFirstResponder()
        isCognitoOperationInProgress = true
        showIndicator(message: "Changing email...")
    
        Amplify.Auth.update(userAttribute: AuthUserAttribute(.email, value: email)) { result in
                do {
                    let updateResult = try result.get()
                    switch updateResult.nextStep {
                    case .confirmAttributeWithCode(let deliveryDetails, let info):
                        print("Confirm the attribute with details send to - \(deliveryDetails) \(String(describing: info))")
                        self.emailChangeSuccess(newEmail: email)
                    case .done:
                        print("Update completed")
                    }
                } catch {
                    print("Update attribute failed with error \(error)")
                }
            }
    }
    
    private func showIndicator(message: String) -> Void {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = message
        hud.show(in: (navigationController?.view)!)
    }

    private func confirmEmailChange(confirmationCode: String) -> Void {
        guard !isCognitoOperationInProgress else { return }
        
        guard ServiceStatus.isValidConfirmationCode(confirmationCode: confirmationCode) else {
            showAlert(title: "Error", message: "Invalid confirmation code")
            return
        }
        
        isCognitoOperationInProgress = true
        showIndicator(message: "Confirming change...")
        
        Amplify.Auth.confirm(userAttribute: .email, confirmationCode: confirmationCode) { result in
                switch result {
                case .success:
                    print("Email attribute verified")
                    self.emailChangeConfirmationSuccess()
                case .failure(let error):
                    print("Email attribute update failed with error \(error)")
                    self.emailChangeConfirmationFailure(error: error)
                }
            }
    }

    private func emailChangeSuccess(newEmail: String) -> Void {
        self.isCognitoOperationInProgress = false
        KeyChain.username = newEmail
        
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.hiddenConfirmationCodeField.becomeFirstResponder()
        }
    }
    
    private func emailChangeConfirmationSuccess() -> Void {
        self.isCognitoOperationInProgress = false
        
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.hiddenConfirmationCodeField.resignFirstResponder()
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: Notification.Name.EmailChangeSuccess, object: nil, userInfo: nil)
        }
    }

    private func emailChangeFailure(error: AuthError) -> Void {
        self.isCognitoOperationInProgress = false
        
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.showAlert(title: "Reset failed", message: "There was an error changing your email.\(error.errorDescription)")
        }
    }
    
    private func emailChangeConfirmationFailure(error: AuthError) -> Void {
        self.isCognitoOperationInProgress = false
        
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.showErrorAlert(title: "Confirmation failed", message: "There was an error confirming the operation. \(error.errorDescription)")
        }
    }

}

extension ChangeEmailViewController : KAPinFieldDelegate {
  func pinField(_ field: KAPinField, didFinishWith code: String) {
    print("didFinishWith : \(code)")
    self.confirmEmailChange(confirmationCode: code)
  }
}

