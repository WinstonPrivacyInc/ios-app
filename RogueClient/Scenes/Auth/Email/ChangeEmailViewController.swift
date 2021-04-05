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

class ChangeEmailViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordView: UIView!
    private var isRequestingReset = false
    private let hud = JGProgressHUD(style: .dark)
    private var passwordResetUsername: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "changeEmailScreen"
        navigationController?.navigationBar.prefersLargeTitles = false
        initNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861 Remove when fixed in future releases
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
    private func initNavigationBar() {
        if isPresentedModally {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissViewController(_:)))
        }
    }

//    @IBAction func passwordReset(_ sender: Any) {
//        
//        guard !isRequestingReset else { return }
//        
//        isRequestingReset = true
//        let email = (self.emailTextField.text ?? "").trim()
//        
//        guard ServiceStatus.isValidEmail(email: email) else {
//            isRequestingReset = false
//            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
//            return
//        }
//        
//        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
//        hud.detailTextLabel.text = "Requesting password reset..."
//        hud.show(in: (navigationController?.view)!)
//        
//        emailTextField.resignFirstResponder()
//        
//        passwordResetUsername = email
//        
//        Amplify.Auth.resetPassword(for: email) { result in
//            do {
//                let resetResult = try result.get()
//                switch resetResult.nextStep {
//             
//                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
//                    print("Confirm reset password with code send to - \(deliveryDetails) \(String(describing: info))")
//                    self.passwordResetSuccess()
//                case .done:
//                    print("Reset completed")
//                }
//            } catch (let error) {
//                print("Password reset failure \(error)")
//                self.passwordResetFailure(error: error)
//            }
//        }
//    }
//    
//    private func passwordResetSuccess() -> Void {
//        self.isRequestingReset = false
//        DispatchQueue.main.async {
//            self.hud.dismiss()
//            self.performSegue(withIdentifier: "ForgotPasswordConfirm", sender: self)
//        }
//    }
//    
//    private func passwordResetFailure(error: Error) -> Void {
//        self.isRequestingReset = false
//        DispatchQueue.main.async {
//            self.hud.dismiss()
//            self.showAlert(title: "Reset failed", message: "There was an error verifying the reset code.\(error)")
//        }
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ForgotPasswordConfirm" {
//            if let destinationVC = segue.destination as? ForgotPasswordConfirmViewController {
//                destinationVC.passwordResetUsername = passwordResetUsername
//            }
//        }
//    }
}
