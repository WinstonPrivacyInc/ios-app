//
//  GeoLookup.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Antonio Campos on 2021-05-02.
//  Copyright (c) 2021 Winston Privacy, Inc.
//
//  This file is part of the Rogue iOS app.
//

import Foundation

struct GeoLookup: Decodable {
    let ipAddress: String
    let isp: String
    let organization: String
    let country: String
    let countryCode: String
    let city: String
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case ipAddress = "ip_address"
        case isp
        case organization
        case country
        case countryCode = "country_code"
        case city
        case latitude
        case longitude
    }
}
