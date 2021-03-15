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

struct InterfaceResult: Decodable {
    var endpoint: String
    var dns: String
    var allowed_ips: String
    var keep_alive: Int
    var public_key: String
    // var ipAddress: String
}

//struct NetworkError: Decodable {
//    error: String
//}

//{"endpoint":"13.59.81.71:51820","dns":"1.1.1.2","allowed_ips":"192.168.0.2/32","keep_alive":0,"public_key":"SJue4OvxWi4EwGkGZ5vKNb61hU4akFm1cV65tNcfyGU=","error":""}
