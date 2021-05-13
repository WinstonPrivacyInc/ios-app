//
//  VPNServerViewModel.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2019-01-28.
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

struct VPNServerViewModel {
    
    // MARK: - Properties -
    
    var server: VPNServer
    
    var imageNameForPingTimeForMainScreen: String {
        if server.randomServerLabelShouldBePresented {
            return ""
        }
        
        return imageNameForPingTime
    }
    
    var formattedServerNameForMainScreen: String {
        if server.randomServerLabelShouldBePresented {
            return "Random server"
        }
        
        return formattedServerName
    }
    
    var imageForCountryCodeForMainScreen: UIImage? {
        if server.randomServerLabelShouldBePresented {
            let image = UIImage(named: "icon-shuffle")
            image?.accessibilityIdentifier = "icon-shuffle"
            return image
        }
        
        return UIImage(named: server.countryCode.uppercased())
    }
    
    var formattedServerNameForSettings: String {
        // FIXME: Antonio - because we only have one server... it ends up being the fastests...
        // reset when we add more servers
//        if server.fastest {
//            return "Fastest server"
//        }
//
//        if server.random {
//            return "Random server"
//        }
        
        return formattedServerName
    }
    
    var imageForCountryCodeForSettings: UIImage? {
        // FIXME: Antonio - because we only have one server... it ends up being the fastests...
        // reset when we add more servers
//        if server.fastest {
//            let image = UIImage(named: "icon-fastest-server")
//            image?.accessibilityIdentifier = "icon-fastest-server"
//            return image
//        }
//
//        if server.random {
//            let image = UIImage(named: "icon-shuffle")
//            image?.accessibilityIdentifier = "icon-shuffle"
//            return image
//        }
        
        return UIImage(named: server.countryCode.uppercased())
    }
    
    var imageNameForPingTime: String {
        guard let pingMs = server.pingMs else { return "" }
        if pingMs >= 0 && pingMs < 100 { return "icon-circle-green" }
        if pingMs >= 100 && pingMs < 300 { return "icon-circle-orange" }
        return "icon-circle-red"
    }
    
    var formattedServerName: String {
        return "\(server.city), \(server.countryCode.uppercased())"
    }
    
    var imageForCountryCode: UIImage? {
        return UIImage(named: server.countryCode.uppercased())
    }
    
    var imageNameForCountryCode: String {
        return server.countryCode.uppercased()
    }
    
    var imageForPingTime: UIImage? {
        if server.pingMs == nil { return nil }
        return UIImage(named: imageNameForPingTime)
    }
    
    // MARK: - Initialize -
    
    init(server: VPNServer) {
        self.server = server
    }
    
    // MARK: - Methods -
    
    func formattedServerName(sort: ServersSort) -> String {
        guard sort != .country else {
            return "\(server.countryCode.uppercased()), \(server.city)"
        }
        
        return "\(server.city), \(server.countryCode.uppercased())"
    }
    
}
