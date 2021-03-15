//
//  ForgotPasswordViewController.swift
//  RogueClient
//
//  Created by Antonio Campos on 3/11/21.
//  Copyright © 2021 Rogue. All rights reserved.
//

import Foundation
import UIKit

class ForgotPasswordViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "forgotPasswordScreen"
//        navigationController?.navigationBar.prefersLargeTitles = false
//
//        addObservers()
//        hideKeyboardOnTap()
    }
    @IBAction func passwordReset(_ sender: Any) {
        print("password reset clicked...")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861
        // Remove when fixed in future releases
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
}
