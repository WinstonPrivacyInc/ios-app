//
//  AppKeyManager.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Antonio Campos on 2021-05-11.
//  Copyright (c) 2021 Winston Privacy, Inc.
//
//  This file is part of the Rogue iOS app.
//

import Foundation
import Ipify

@objc protocol AppKeyManagerDelegate: class {
    func setKeyStart()
    func setKeySuccess()
    func setKeyFail()
}

class AppKeyManager {

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
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        }
 
    }
    
}
