//
//  ConfirmationViewController.swift
//  RogueClient
//
//  Created by Antonio Campos on 4/6/21.
//  Copyright © 2021 Winston Privacy. All rights reserved.
//

import Foundation
import UIKit
import KAPinField

class ConfirmationViewController: UIViewController {
    
    @IBOutlet weak var confirmationCodeField: KAPinField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmationCodeField.properties.delegate = self
        confirmationCodeField.properties.numberOfCharacters = 6
        confirmationCodeField.properties.isSecure = false
        confirmationCodeField.properties.animateFocus = true
        _ = confirmationCodeField.becomeFirstResponder()
    }
}

extension ConfirmationViewController : KAPinFieldDelegate {
  func pinField(_ field: KAPinField, didFinishWith code: String) {
    print("didFinishWith : \(code)")
  }
}

