//
//  VPNServerViewModelTests.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2020-06-30.
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

class VPNServerViewModelTests: XCTestCase {
    
    var viewModel = VPNServerViewModel(server: VPNServer(gateway: "nl.wg.ivpn.net", countryCode: "NL", country: "Netherlands", city: "Amsterdam"))
    
    func test_imageNameForPingTime() {
        viewModel.server.pingMs = nil
        XCTAssertEqual(viewModel.imageNameForPingTime, "")
        
        viewModel.server.pingMs = 50
        XCTAssertEqual(viewModel.imageNameForPingTime, "icon-circle-green")
        
        viewModel.server.pingMs = 200
        XCTAssertEqual(viewModel.imageNameForPingTime, "icon-circle-orange")
        
        viewModel.server.pingMs = 400
        XCTAssertEqual(viewModel.imageNameForPingTime, "icon-circle-red")
    }
    
    func test_formattedServerName() {
        XCTAssertEqual(viewModel.formattedServerName, "Amsterdam, NL")
    }
    
    func test_imageNameForCountryCode() {
        XCTAssertEqual(viewModel.imageNameForCountryCode, "NL")
    }
    
    func test_formattedServerNameSort() {
        XCTAssertEqual(viewModel.formattedServerName(sort: .city), "Amsterdam, NL")
        XCTAssertEqual(viewModel.formattedServerName(sort: .latency), "Amsterdam, NL")
        XCTAssertEqual(viewModel.formattedServerName(sort: .proximity), "Amsterdam, NL")
        XCTAssertEqual(viewModel.formattedServerName(sort: .country), "NL, Amsterdam")
    }
    
}
