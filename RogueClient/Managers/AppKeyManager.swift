//
//  AppKeyManager.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2018-10-30.
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
import Ipify

@objc protocol AppKeyManagerDelegate: class {
    func setKeyStart()
    func setKeySuccess()
    func setKeyFail()
}

class AppKeyManager {
    
    // MARK: - Properties -
    
    weak var delegate: AppKeyManagerDelegate?
    
    static var keyTimestamp: Date {
        return UserDefaults.shared.wgKeyTimestamp
    }
    
    static var keyExpirationTimestamp: Date {
        if Config.useDebugWireGuardKeyUpgrade {
            return keyTimestamp.changeMinutes(by: Config.wgKeyExpirationDays)
        }
        
        return keyTimestamp.changeDays(by: Config.wgKeyExpirationDays)
    }
    
    static var keyRegenerationTimestamp: Date {
        let regenerationRate = UserDefaults.shared.wgRegenerationRate
        
        if Config.useDebugWireGuardKeyUpgrade {
            return keyTimestamp.changeMinutes(by: regenerationRate)
        }
        
        let regenerationDate = keyTimestamp.changeDays(by: regenerationRate)
        
        guard regenerationDate > Date() else {
            return Date()
        }
        
        return regenerationDate
    }
    
    static var isKeyExpired: Bool {
        // guard KeyChain.wgPublicKey != nil else { return false }
        guard KeyChain.wgInterfacePublicKey != nil else { return false }
        guard Date() > keyExpirationTimestamp else { return false }
        
        return true
    }
    
    static var isKeyPairRequired: Bool {
        return Application.shared.settings.connectionProtocol.tunnelType() == .wireguard
    }
    
    static func generateKeyPair() {
        // TODO: antonio -> we don't need this method anymore... remove from places where it's still used....
        var interface = Interface()
        interface.privateKey = Interface.generatePrivateKey()
        
        KeyChain.wgInterfacePrivateKey = interface.privateKey
        KeyChain.wgInterfacePublicKey = interface.publicKey
    }
    
    private func getIpAddress(completion: @escaping (String) -> Void) {
        Ipify.getPublicIPAddress { (result) in
            switch result {
            case .success(let ip):
                completion(ip)
            case .failure(let error):
                log(error: "Unable to get public IP address \(String(describing: error))")
                completion("")
            }
        }
    }
    
    func setNewKey(completion: @escaping (Result<Int>) -> Void) {
        
        let keyPair = KeyPair()
        
        self.getIpAddress { (ipAddress) in
            let params = [
                URLQueryItem(name: "ip_address", value: ipAddress),
                URLQueryItem(name: "listen_port", value: "5353"),
                URLQueryItem(name: "public_key", value: keyPair.publicKey),
                URLQueryItem(name: "server_port", value: "51820"),
            ]
            
            let request = ApiRequestDI(method: .post, endpoint: Config.apiSessionWGKeySet, params: params)
            
            ApiService.shared.request(request) { (result: Result<InterfaceResult>) in
                switch result {
                case .success(let wireguardInterface):
                    UserDefaults.shared.set(Date(), forKey: UserDefaults.Key.wgKeyTimestamp)
                    
                    KeyChain.wgInterfacePrivateKey = keyPair.privateKey
                    KeyChain.wgInterfacePublicKey = keyPair.publicKey
                    KeyChain.wgInterfaceDnsServers = wireguardInterface.dns
                    KeyChain.wgInterfaceAddresses = wireguardInterface.allowedIps
                    
                    KeyChain.wgPeerPublicKey = wireguardInterface.publicKey
                    KeyChain.wgPeerEndpoint = wireguardInterface.endpoint
                    KeyChain.wgPeerPersistentKeepAlive = wireguardInterface.keepAlive
                    
                    completion(.success(0))
                    // self.delegate?.setKeySuccess()
                case .failure(let error):
                    completion(.failure(error))
                    // self.delegate?.setKeyFail()
                }
            }
            
        }
        
    
        
//        var interface = Interface()
//        interface.privateKey = Interface.generatePrivateKey()
        
//        let params = ApiService.authParams + [
//            URLQueryItem(name: "public_key", value: interface.publicKey ?? "")
//        ]
        
        
        
        // antonio this throws error
        // TODO: move out of here... why is the background thread making UI updates? UI thread should start this before calling .setNewKey right?
//        DispatchQueue.main.async {
//            self.delegate?.setKeyStart()
//        }
        // delegate?.setKeyStart()
        
        
        // this fails with:
        // Main Thread Checker: UI API called on a background thread:
//        ApiService.shared.request(request) { (result: Result<InterfaceResult>) in
//            switch result {
//            case .success(let model):
//                UserDefaults.shared.set(Date(), forKey: UserDefaults.Key.wgKeyTimestamp)
//                KeyChain.wgPrivateKey = interface.privateKey
//                KeyChain.wgPublicKey = interface.publicKey
//                // KeyChain.wgIpAddress = model.ipAddress
//                KeyChain.wgIpAddress = model.allowed_ips
//                self.delegate?.setKeySuccess()
//            case .failure:
//                self.delegate?.setKeyFail()
//            }
//        }
    }
    
}
