//
//  WireGuardRegenerationRateCell.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2019-04-09.
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

// TODO antonio - remove this class
class WireGuardRegenerationRateCell: UITableViewCell {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var regenerationLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    // MARK: - @IBActions -
    
//    @IBAction func updateRegenerateRate(_ sender: UIStepper) {
//        UserDefaults.shared.set(Int(sender.value), forKey: UserDefaults.Key.wgRegenerationRate)
//        regenerationLabel.text = regenerationLabelText(days: Int(sender.value))
//    }
    @IBAction func updateRegenerateRate(_ sender: UIStepper) {
        UserDefaults.shared.set(Int(sender.value), forKey: UserDefaults.Key.wgRegenerationRate)
        regenerationLabel.text = regenerationLabelText(days: Int(sender.value))
    }
    
    // MARK: - View Lifecycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        regenerationLabel.text = regenerationLabelText(days: UserDefaults.shared.wgRegenerationRate)
        stepper.value = Double(UserDefaults.shared.wgRegenerationRate)
    }
    
    // MARK: - Methods -
    
    private func regenerationLabelText(days: Int) -> String {
        var rotationInterval = ""
        switch days {
        case 1:
            rotationInterval = "day"
        case 2:
            rotationInterval = "two days"
        case 3:
            rotationInterval = "three days"
        case 4:
            rotationInterval = "four days"
        case 5:
            rotationInterval = "five days"
        case 6:
            rotationInterval = "six days"
        case 7:
            rotationInterval = "seven days"
        case 8:
            rotationInterval = "eight days"
        case 9:
            rotationInterval = "nine days"
        default:
            rotationInterval = "\(days) days"
        }
        
        
        return "Rotate key every \(rotationInterval)"
    }
    
}
