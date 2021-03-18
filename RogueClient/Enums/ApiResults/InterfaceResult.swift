//
//  InterfaceResult.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-09-06.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

class InterfaceResult: Decodable {
    let endpoint: String
    let dns: String
    let allowedIps: String
    let keepAlive: Int32
    let publicKey: String
    let error: String
    
//    init() {
//
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case endpoint
//        case dns
//        case allowedIps = "allowed_ips"
//        case keepAlive = "keep_alive"
//        case publicKey = "public_key"
//        case error
//    }
//
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        endpoint = try container.decodeIfPresent(String.self, forKey: .endpoint)
//        dns = try container.decodeIfPresent(String.self, forKey: .dns)
//        allowedIps = try container.decodeIfPresent(String.self, forKey: .allowedIps)
//        keepAlive = try container.decodeIfPresent(Int.self, forKey: .keepAlive)
//        publicKey = try container.decodeIfPresent(String.self, forKey: .publicKey)
//        error = try container.decodeIfPresent(String.self, forKey: .error)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        try container.encodeIfPresent(endpoint, forKey: .endpoint)
//        try container.encodeIfPresent(dns, forKey: .dns)
//        try container.encodeIfPresent(allowedIps, forKey: .allowedIps)
//        try container.encodeIfPresent(keepAlive, forKey: .keepAlive)
//        try container.encodeIfPresent(publicKey, forKey: .publicKey)
//        try container.encodeIfPresent(error, forKey: .error)
//    }
}

//{"endpoint":"13.59.81.71:51820","dns":"1.1.1.2","allowed_ips":"192.168.0.2/32","keep_alive":0,"public_key":"SJue4OvxWi4EwGkGZ5vKNb61hU4akFm1cV65tNcfyGU=","error":""}
