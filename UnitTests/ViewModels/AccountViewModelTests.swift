//
//  AccountViewModelTests.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2020-03-24.
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

class AccountViewModelTests: XCTestCase {
    
    override func setUp() {
        Application.shared.authentication.removeStoredCredentials()
    }
    
    func test_statusText() {
        var viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        
        viewModel.serviceStatus.isActive = false
        XCTAssertEqual(viewModel.statusText, "INACTIVE")
        
        viewModel.serviceStatus.isActive = true
        XCTAssertEqual(viewModel.statusText, "ACTIVE")
    }
    
    func test_subscriptionText() {
        var viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        viewModel.serviceStatus.currentPlan = "IVPN Standard"
        
        viewModel.serviceStatus.isActive = false
        XCTAssertEqual(viewModel.subscriptionText, "IVPN Standard")
        
        viewModel.serviceStatus.isActive = true
        XCTAssertEqual(viewModel.subscriptionText, "IVPN Standard")
    }
    
    func test_activeUntilText() {
        var viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        
        viewModel.serviceStatus.isActive = false
        XCTAssertEqual(viewModel.activeUntilText, "No active subscription")
    }
    
}
