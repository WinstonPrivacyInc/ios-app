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
    
    private var isRequestingReset = false
    private let hud = JGProgressHUD(style: .dark)
    @IBOutlet weak var resetCodeField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "forgotPasswordConfirmScreen"
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
        
        resetCodeField.becomeFirstResponder()
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
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Resetting your password..."
        hud.show(in: (navigationController?.view)!)
        
        
        
    }
    
    @IBAction func goBack() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func removethisplease(_ sender: Any) {
        
   
        
        hud.dismiss()
        
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
