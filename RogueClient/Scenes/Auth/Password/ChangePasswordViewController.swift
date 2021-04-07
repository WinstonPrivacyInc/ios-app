//
//  ChangePasswordViewController.swift
//  RogueClient
//
//  Created by Antonio Campos on 4/5/21.
//  Copyright © 2021 Winston Privacy. All rights reserved.
//

import Foundation
import UIKit
import JGProgressHUD
import Amplify

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var currentPasswordField: UITextFieldPadding!
    @IBOutlet weak var newPasswordField: UITextFieldPadding!
    let hud = JGProgressHUD(style: .dark)
    private var isChangingPassword = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "changePasswordScreen"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861 Remove when fixed in future releases
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }

        
    }
    
    
    @IBAction func changePassword(_ sender: Any) {
        guard !isChangingPassword else { return }
        
        isChangingPassword = true
        
        currentPasswordField.isSecureTextEntry = false
        newPasswordField.isSecureTextEntry = false
        let currentPassword = (currentPasswordField.text ?? "").trim()
        let newPassword  = (newPasswordField.text ?? "").trim()
        currentPasswordField.isSecureTextEntry = true
        newPasswordField.isSecureTextEntry = true
        
        guard !currentPassword.isEmpty else {
            showAlert(title: "Error", message: "Enter your current password.")
            return
        }
        
        guard ServiceStatus.isValidPassword(password: newPassword) else {
            showAlert(title: "Error", message: "Enter a valid new password.")
            return
        }
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Changing password..."
        hud.show(in: (navigationController?.view)!)
        
        Amplify.Auth.update(oldPassword: currentPassword, to: newPassword) { result in
                switch result {
                case .success:
                    print("Change password succeeded")
                    self.passwordChangeSuccess()
                case .failure(let error):
                    print("Change password failed with error \(error)")
                    self.passwordChangeFailure(error: error)
                }
            }
    }
    
    private func passwordChangeSuccess() -> Void {
        self.isChangingPassword = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: Notification.Name.PasswordChangeSuccess, object: nil, userInfo: nil)
        }
    }
    
    private func passwordChangeFailure(error: AuthError) -> Void {
        self.isChangingPassword = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.showAlert(title: "Update failed", message: error.errorDescription)
        }
    }
    

}
