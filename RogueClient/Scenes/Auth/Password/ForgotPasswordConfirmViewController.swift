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

class ForgotPasswordConfirmViewController: UIViewController {
    
    var passwordResetUsername: String = ""
    private var isRequestingReset = false
    private let hud = JGProgressHUD(style: .dark)
    @IBOutlet weak var resetCodeField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "signUpConfirmScreen"
         navigationController?.navigationBar.prefersLargeTitles = false
        initNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861
        // Remove when fixed in future releases
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
        
         // resetCodeField.becomeFirstResponder()
    }
    
    private func initNavigationBar() {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        guard !isRequestingReset else { return }
        
        isRequestingReset = true
        
        let resetCode = (self.resetCodeField.text ?? "").trim()
        
        guard !resetCode.isEmpty else {
            showAlert(title: "Invalid Code", message: "Please enter a valid reset code.")
            isRequestingReset = false
            return
        }
        
        let newPassword = (self.newPasswordField.text ?? "").trim()
        
        guard ServiceStatus.isValidPassword(password: newPassword) else {
            isRequestingReset = false
            showAlert(title: "Invalid Password", message: "Please enter your password.")
            return
        }
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Resetting your password..."
        hud.show(in: (navigationController?.view)!)
        
        Amplify.Auth.confirmResetPassword(for: passwordResetUsername, with: newPassword, confirmationCode: resetCode) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.onResetSuccess()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.onResetFailure(error: error)
                }
            }
        }
    }
    
    private func onResetSuccess() {
        print("Password reset confirmed")
        self.isRequestingReset = false
        self.hud.dismiss()
        self.dismissViewController(self)
        
        let data = ["email": self.passwordResetUsername]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name.PasswordResetSuccess.rawValue), object: nil, userInfo: data)
    }
    
    private func onResetFailure(error: AuthError) {
        print("Reset password failed with error \(error)")
        self.isRequestingReset = false
        self.hud.dismiss()
        self.showAlert(title: "Error", message: error.errorDescription)
    }
    
    @IBAction func goBack() {
        navigationController?.popViewController(animated: true)
    }

}
