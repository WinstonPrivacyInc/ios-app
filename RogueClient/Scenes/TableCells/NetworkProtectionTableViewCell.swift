//
//  NetworkProtectionTableViewCell.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2018-11-21.
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

class NetworkProtectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var trustLabel: UILabel!
    @IBOutlet weak var defaultTrustLabel: UILabel!
    @IBOutlet weak var trustLabelTopConstraint: NSLayoutConstraint!
    
    // MARK: - Methods -
    
    func render(network: Network, defaultNetwork: Network?) {
        nameLabel.text = network.name
        trustLabel.text = network.trust?.uppercased()
        
        if let defaultNetwork = defaultNetwork {
            defaultTrustLabel.text = defaultNetwork.trust
        } else {
            defaultTrustLabel.text = NetworkTrust.None.rawValue
        }
        
        switch network.trust {
        case NetworkTrust.Untrusted.rawValue:
            trustLabel.textColor = UIColor.init(named: Theme.ivpnRed)
            setTrustLayout(withDefault: false)
        case NetworkTrust.Trusted.rawValue:
            trustLabel.textColor = UIColor.init(named: Theme.ivpnGreen)
            setTrustLayout(withDefault: false)
        default:
            trustLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
            setTrustLayout(withDefault: true)
        }
        
        if network.isDefault {
            setTrustLayout(withDefault: false)
        }
    }
    
    private func setTrustLayout(withDefault: Bool) {
        defaultTrustLabel.isHidden = !withDefault
        
        if withDefault {
            trustLabelTopConstraint.constant = 8
        } else {
            trustLabelTopConstraint.constant = 17
        }
    }
    
}
