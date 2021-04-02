//
//  ProductIdentifier.swift
//  RogueClient
//
//  Created by Juraj Hilje on 18/04/2019.
//  Copyright © 2019 Winston Privacy. All rights reserved.
//

//
//  ProductIdentifier.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2019-04-18.
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

import Foundation

struct ProductIdentifier {
    
    static let standardWeek = "net.ivpn.subscriptions.standard.1week"
    static let standardMonth = "net.ivpn.subscriptions.standard.1month"
    static let standardYear = "net.ivpn.subscriptions.standard.1year"
    static let standardTwoYears = "net.ivpn.subscriptions.standard.2year"
    static let standardThreeYears = "net.ivpn.subscriptions.standard.3year"
    static let proWeek = "net.ivpn.subscriptions.pro.1week"
    static let proMonth = "net.ivpn.subscriptions.pro.1month"
    static let proYear = "net.ivpn.subscriptions.pro.1year"
    static let proTwoYears = "net.ivpn.subscriptions.pro.2year"
    static let proThreeYears = "net.ivpn.subscriptions.pro.3year"
    
    static var all: Set<String> {
        return [
            standardWeek,
            standardMonth,
            standardYear,
            standardTwoYears,
            standardThreeYears,
            proWeek,
            proMonth,
            proYear,
            proTwoYears,
            proThreeYears
        ]
    }
    
}
