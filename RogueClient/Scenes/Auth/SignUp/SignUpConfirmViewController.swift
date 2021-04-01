//
//  SignupConfirmViewController.swift
//  RogueClient
//
//  Created by Antonio Campos on 3/11/21.
//  Copyright © 2021 Winston Privacy. All rights reserved.
//

import Foundation
import UIKit
import JGProgressHUD
import Amplify

class SignUpConfirmViewController: UIViewController {
    // controller inputs
    var signUpUsername: String = ""
    var signUpPassword: String = ""
    
    private var isConfirmingEmail = false
    private let hud = JGProgressHUD(style: .dark)
    @IBOutlet weak var confirmationCodeTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "signUpConfirmScreen"
        navigationController?.navigationBar.prefersLargeTitles = false
        initNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
        
        confirmationCodeTextField.becomeFirstResponder()
    }
    
    private func initNavigationBar() {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @IBAction func confirmSignUp(_ sender: Any) {
        guard !isConfirmingEmail else { return }
        
        isConfirmingEmail = true
        
        let confirmationCode = (self.confirmationCodeTextField.text ?? "").trim()
        
        guard !confirmationCode.isEmpty else {
            showAlert(title: "Invalid Code", message: "Please enter a valid confirmation code.")
            isConfirmingEmail = false
            return
        }
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Confirming your email..."
        hud.show(in: (navigationController?.view)!)
        
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
        self.isConfirmingEmail = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.dismissViewController(self)
            
            let data = ["email": self.signUpUsername, "password": self.signUpPassword]
            NotificationCenter.default.post(name: Notification.Name.EmailConfirmationSuccess, object: nil, userInfo: data)
        }
    }
    
    private func emailConfirmFailure(error: AuthError) -> Void {
        print("Email confirmation failed with error \(error)")
        self.isConfirmingEmail = false
        self.hud.dismiss()
        self.showAlert(title: "Error", message: error.errorDescription)
    }
    
    @IBAction func goBack() {
        navigationController?.popViewController(animated: true)
    }

}
