//
//  ForgotPasswordView.swift
//  RogueClient
//
//  Created by Antonio Campos on 3/11/21.
//  Copyright © 2021 Rogue. All rights reserved.
//

import UIKit
import SnapKit

class ForgotPasswordConfirmView: UIView {
    
    
    
//    @IBOutlet weak var accountLabel: UILabel!
//    @IBOutlet weak var accountView: UIView!
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setupView()
        setupLayout()
    }
    
    // MARK: - Private methods -
    
    private func setupView() {
        // accountLabel.text = KeyChain.tempUsername ?? ""
    }
    
    private func setupLayout() {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            accountView.snp.makeConstraints { make in
//                make.left.equalTo(21)
//                make.right.equalTo(-21)
//            }
//        }
        
    }
    
}

