//
//  ErrorResultSessionNew.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2019-10-14.
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

struct SessionLimitData: Decodable {
    let limit: Int
    let currentPlan: String
    let upgradable: Bool
    let upgradeToPlan: String
    let upgradeToUrl: String
    let paymentMethod: String
}

struct ErrorResultSessionNew: Decodable {
    let status: Int
    let message: String
    let data: SessionLimitData?
    let captchaId: String?
    let captchaImage: String?
}
