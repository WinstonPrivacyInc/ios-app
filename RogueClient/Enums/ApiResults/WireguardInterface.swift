//
//  WireguardInterface.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Antonio Campos on 2021-05-13.
//  Copyright (c) 2021 Winston Privacy, Inc.
//
//  This file is part of the Rogue iOS app.
//

import Foundation

class WireguardInterface: Decodable {
    let endpoint: String
    let dns: String
    let allowedIps: String
    let keepAlive: Int32
    let publicKey: String
    let error: String
    
    enum CodingKeys: String, CodingKey {
        case endpoint
        case dns
        case allowedIps = "allowed_ips"
        case keepAlive = "keep_alive"
        case publicKey = "public_key"
        case error
    }
}
