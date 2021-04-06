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
    @IBOutlet weak var changeEmailView: UIView!
    private var isChangingEmail = false
    private var currentEmail = ""
    private let hud = JGProgressHUD(style: .dark)
    private var passwordResetUsername: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "changeEmailScreen"
        // navigationController?.navigationBar.prefersLargeTitles = false
        initNavigationBar()
        
        Application.shared.authentication.getUserAttribute(key: .email) { (email) in
            DispatchQueue.main.async {
                self.currentEmail = email ?? ""
                self.emailTextField.text = self.currentEmail
                self.emailTextField.becomeFirstResponder()
            }
        }
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
            // navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissViewController(_:)))
        }
    }

    @IBAction func changeEmail(_ sender: Any) {
        present(NavigationManager.getConfirmationCodeViewController(), animated: true)
        return

        guard !isChangingEmail else { return }

        isChangingEmail = true
        let email = (self.emailTextField.text ?? "").trim()
        
        guard email != self.currentEmail else {
            isChangingEmail = false
            showAlert(title: "No Change", message: "Please enter a new email address.")
            return
        }

        guard ServiceStatus.isValidEmail(email: email) else {
            isChangingEmail = false
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }

        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Changing email..."
        hud.show(in: (navigationController?.view)!)

        emailTextField.resignFirstResponder()
        
        
        
        // showConfirmationAlert(title: "", message: "Enter the confirmation code sent to your email", action: "Confirm")
        
        
//        Amplify.Auth.update(userAttribute: AuthUserAttribute(.email, value: email)) { result in
//                do {
//                    let updateResult = try result.get()
//                    switch updateResult.nextStep {
//                    case .confirmAttributeWithCode(let deliveryDetails, let info):
//                        print("Confirm the attribute with details send to - \(deliveryDetails) \(String(describing: info))")
//                        self.emailChangeSuccess()
//                    case .done:
//                        print("Update completed")
//                    }
//                } catch {
//                    print("Update attribute failed with error \(error)")
//                }
//            }
    }
//
    private func emailChangeSuccess() -> Void {
        self.isChangingEmail = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.performSegue(withIdentifier: "EmailChangeConfirm", sender: self)
//            self.navigationController?.popViewController(animated: true)
//            NotificationCenter.default.post(name: Notification.Name.EmailChangeSuccess, object: nil, userInfo: nil)
        }
    }

    private func emailChangeFailure(error: Error) -> Void {
        self.isChangingEmail = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.showAlert(title: "Reset failed", message: "There was an error verifying the reset code.\(error)")
        }
    }

}
