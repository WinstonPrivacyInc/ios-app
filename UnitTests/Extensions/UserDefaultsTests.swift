//
//  UserDefaultsTests.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2020-02-11.
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

import XCTest

@testable import RogueClient

class UserDefaultsTests: XCTestCase {
    
    func test_properties() {
        XCTAssertNotNil(UserDefaults.shared.wireguardTunnelProviderError)
        XCTAssertNotNil(UserDefaults.shared.isMultiHop)
        XCTAssertNotNil(UserDefaults.shared.exitServerLocation)
        XCTAssertNotNil(UserDefaults.shared.isLogging)
        XCTAssertNotNil(UserDefaults.shared.networkProtectionEnabled)
        XCTAssertNotNil(UserDefaults.shared.networkProtectionUntrustedConnect)
        XCTAssertNotNil(UserDefaults.shared.networkProtectionTrustedDisconnect)
        XCTAssertNotNil(UserDefaults.shared.isCustomDNS)
        XCTAssertNotNil(UserDefaults.shared.customDNS)
        XCTAssertNotNil(UserDefaults.shared.isAntiTracker)
        XCTAssertNotNil(UserDefaults.shared.isAntiTrackerHardcore)
        XCTAssertNotNil(UserDefaults.shared.antiTrackerDNS)
        XCTAssertNotNil(UserDefaults.shared.antiTrackerDNSMultiHop)
        XCTAssertNotNil(UserDefaults.shared.antiTrackerHardcoreDNS)
        XCTAssertNotNil(UserDefaults.shared.antiTrackerHardcoreDNSMultiHop)
        XCTAssertNotNil(UserDefaults.shared.wgKeyTimestamp)
        XCTAssertNotNil(UserDefaults.shared.wgRegenerationRate)
        XCTAssertNotNil(UserDefaults.shared.serversSort)
    }
    
}
