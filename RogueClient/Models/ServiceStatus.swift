//
//  ServiceStatus.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2019-08-09.
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

struct ServiceStatus: Codable {
    
    // MARK: - Properties -
    
    var isActive: Bool
    #warning("currentPlan should not be optional, change this after API is fixed")
    var currentPlan: String?
    var activeUntil: Int?
    var isOnFreeTrial: Bool?
    let username: String?
    let upgradeToUrl: String?
    let paymentMethod: String?
    let capabilities: [String]?
    
    private static let serviceStatusKey = "ServiceStatus"
    
    // MARK: - Initialize -
    
    init() {
        let service = ServiceStatus.load()
        isActive = service?.isActive ?? true
        currentPlan = service?.currentPlan ?? nil
        activeUntil = service?.activeUntil ?? nil
        isOnFreeTrial = service?.isOnFreeTrial ?? false
        username = service?.username ?? nil
        upgradeToUrl = service?.upgradeToUrl ?? nil
        paymentMethod = service?.paymentMethod ?? nil
        capabilities = service?.capabilities ?? nil
    }
    
    // MARK: - Methods -
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: ServiceStatus.serviceStatusKey)
        }
    }
    
    static func load() -> ServiceStatus? {
        if let savedObj = UserDefaults.standard.object(forKey: ServiceStatus.serviceStatusKey) as? Data {
            if let loadedObj = try? JSONDecoder().decode(ServiceStatus.self, from: savedObj) {
                return loadedObj
            }
        }
        
        return nil
    }
    
    func activeUntilString() -> String {
        return Date(timeIntervalSince1970: TimeInterval(activeUntil ?? 0)).formatDate()
    }
    
    func isEnabled(capability: Capability) -> Bool {
        if let capabilities = self.capabilities {
            return capabilities.contains(capability.rawValue)
        }
        
        return false
    }
    
    static func isValid(username: String) -> Bool {
        return username.hasPrefix("ivpn") || username.hasPrefix("i-")
    }
    
    static func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    static func isValidPassword(password: String) -> Bool {
        return !password.isEmpty
    }
    
    static func isValidConfirmationCode(confirmationCode: String) -> Bool {
        return !confirmationCode.isEmpty && confirmationCode.count == 6
    }
    
    static func isValid(verificationCode: String) -> Bool {
        return !verificationCode.isEmpty && verificationCode.count == 6 && NumberFormatter().number(from: verificationCode) != nil
    }
    
    func isNewStyleAccount() -> Bool {
        return paymentMethod == "prepaid"
    }
    
    func daysUntilSubscriptionExpiration() -> Int {
        let calendar = Calendar.current
        let startDate = Date()
        let endDate = Date(timeIntervalSince1970: TimeInterval(activeUntil ?? 0))
        let date1 = calendar.startOfDay(for: startDate)
        let date2 = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        let diff = components.day ?? 0
        
        return diff > 0 ? diff : 0
    }
    
    func isActiveUntilValid() -> Bool {
        return activeUntil != nil && (activeUntil ?? 0) > 0
    }
    
}
