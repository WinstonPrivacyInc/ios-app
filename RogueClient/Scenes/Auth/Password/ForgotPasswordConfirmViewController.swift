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
    
    enum ResetMode {
        case resetting
        case confirming
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordView: UIView!
    @IBOutlet weak var confirmPasswordView: UIView!
    private var isRequestingReset = false
    private let hud = JGProgressHUD(style: .dark)
    private var resetMode = ResetMode.resetting
    
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "forgotPasswordConfirmScreen"
        navigationController?.navigationBar.prefersLargeTitles = false
        initNavigationBar()
        updateViewMode()
//
//        addObservers()
//        hideKeyboardOnTap()
    }
    
    private func updateViewMode() {
//        if resetMode == ResetMode.resetting {
//            emailTextField.becomeFirstResponder()
//            resetPasswordView.isHidden = false
//            confirmPasswordView.isHidden = true
//            
//        } else {
//            resetPasswordView.isHidden = true
//            confirmPasswordView.isHidden = false
//        }
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
        
       
        
        emailTextField.resignFirstResponder()
        
        hud.dismiss()
        resetMode = ResetMode.confirming
        
        // updateViewMode()
        present(NavigationManager.getForgotPasswordConfirmController(), animated: true)
        
        
//        Amplify.Auth.resetPassword(for: email) { (result) in
//            do {
//                let resetResult = try result.get()
//                switch resetResult.nextStep {
//                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
//                    print("Confirm reset password with code send to - \(deliveryDetails) \(String(describing: info))")
//                case .done:
//                    print("Reset completed")
//                }
//            } catch {
//                print("Reset password failed with error \(error)")
//            }
//        }
        
    }
}
