//
//  CreateAccountView.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2020-04-16.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the Rogue iOS app.
//
//  The Rogue iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Rogue iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the Rogue iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import SnapKit

class CreateAccountView: UIView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var accountView: UIView!
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setupView()
        setupLayout()
    }
    
    // MARK: - Private methods -
    
    private func setupView() {
        accountLabel.text = KeyChain.tempUsername ?? ""
    }
    
    private func setupLayout() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            accountView.snp.makeConstraints { make in
                make.left.equalTo(21)
                make.right.equalTo(-21)
            }
        }
        
    }
    
}
