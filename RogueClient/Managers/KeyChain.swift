//
//  KeyChain.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Antonio Campos on 2021-05-10.
//  Copyright (c) 2021 Winston Privacy, Inc
//
//  This file is part of the Rogue iOS app.
//

import KeychainAccess

class KeyChain {
    
    private static let usernameKey = "username"
    private static let tempUsernameKey = "tempUsernameKey"
    private static let sessionTokenKey = "session_token"
    private static let vpnUsernameKey = "vpn_username"
    private static let vpnPasswordKey = "vpn_password"
    
    private static let wgInterface_privateKey_key = "wg_interface_private_key"
    private static let wgInterface_publicKey_key = "wg_interface_public_key"
    private static let wgInterface_addresses_key = "wg_interface_addresses"
    private static let wgInterface_listenPort_key = "wg_interface_listen_port"
    private static let wgInterface_dnsServers_key = "wg_interface_dns_servers"
    private static let wgPeer_publicKey_key = "wg_peer_public_key"
    private static let wgPeer_endpoint_key = "wg_peer_endpoint"
    private static let wgPeer_persistentKeepAlive_key = "wg_peer_persistent_keep_alive"
    
    static let bundle: Keychain = {
        return Keychain(service: "com.winstonprivacy.rogue", accessGroup: "4TSHK25NM3.com.winstonprivacy.rogue")
    }()
    
    class var wgInterfacePrivateKey: String? {
        get { return KeyChain.bundle[wgInterface_privateKey_key] }
        set { KeyChain.bundle[wgInterface_privateKey_key] = newValue }
    }
    
    class var wgInterfacePublicKey: String? {
        get {
            return KeyChain.bundle[wgInterface_publicKey_key] }
        set { KeyChain.bundle[wgInterface_publicKey_key] = newValue }
    }
    
    class var wgInterfaceAddresses: String? {
        get { return KeyChain.bundle[wgInterface_addresses_key] }
        set { KeyChain.bundle[wgInterface_addresses_key] = newValue }
    }
        
    class var wgInterfaceListenPort: Int? {
        get {
            guard let listenPort = KeyChain.bundle[wgInterface_listenPort_key] else {
                return Config.wgInterfaceListenPort
            }
            return Int(listenPort)
        }
        set {
            let listenPort = newValue ?? Config.wgInterfaceListenPort
            KeyChain.bundle[wgInterface_listenPort_key] = String(listenPort)
        }
    }
    
    class var wgInterfaceDnsServers: String? {
        get { return KeyChain.bundle[wgInterface_dnsServers_key] }
        set { KeyChain.bundle[wgInterface_dnsServers_key] = newValue }
    }
    
    class var wgPeerPublicKey: String? {
        get { return KeyChain.bundle[wgPeer_publicKey_key] }
        set { KeyChain.bundle[wgPeer_publicKey_key] = newValue }
    }
    
    class var wgPeerEndpoint: String? {
        get { return KeyChain.bundle[wgPeer_endpoint_key] }
        set { KeyChain.bundle[wgPeer_endpoint_key] = newValue }
    }
    
    class var wgPeerPersistentKeepAlive: Int32? {
        get {
            guard let keepAlive = KeyChain.bundle[wgPeer_persistentKeepAlive_key]  else {
                return Config.wgPeerPersistentKeepalive
            }
            return Int32(keepAlive)
        }
        set {
            let keepAlive = newValue ?? Config.wgPeerPersistentKeepalive
            KeyChain.bundle[wgPeer_persistentKeepAlive_key] = String(keepAlive)
        }
    }
    
    class var username: String? {
        get {
            return KeyChain.bundle[usernameKey]
        }
        set {
            KeyChain.bundle[usernameKey] = newValue
        }
    }
    
    class var tempUsername: String? {
        get {
            return KeyChain.bundle[tempUsernameKey]
        }
        set {
            KeyChain.bundle[tempUsernameKey] = newValue
        }
    }
    
    class var sessionToken: String? {
        get {
            return KeyChain.bundle[sessionTokenKey]
        }
        set {
            KeyChain.bundle[sessionTokenKey] = newValue
        }
    }
    
    class var vpnUsername: String? {
        get {
            return KeyChain.bundle[vpnUsernameKey]
        }
        set {
            KeyChain.bundle[vpnUsernameKey] = newValue
        }
    }
    
    class var vpnPassword: String? {
        get {
            return KeyChain.bundle[vpnPasswordKey]
        }
        set {
            KeyChain.bundle[vpnPasswordKey] = newValue
        }
    }
    
    class var vpnPasswordRef: Data? {
        return KeyChain.bundle[attributes: vpnPasswordKey]?.persistentRef
    }
    
    static func save(session: Session) {
        sessionToken = session.token
        vpnUsername = session.vpnUsername
        vpnPassword = session.vpnPassword
        
//        if let wireguardResult = session.wireguard, let ipAddress = wireguardResult.ipAddress {
//            KeyChain.wgIpAddress = ipAddress
//        }
    }
    
    static func clearAll() {
        username = nil
        tempUsername = nil
        // wgPrivateKey = nil
        // wgPublicKey = nil
        // wgIpAddress = nil
        sessionToken = nil
        vpnUsername = nil
        vpnPassword = nil
        
        wgInterfacePrivateKey = nil
        wgInterfacePublicKey = nil
        wgInterfaceAddresses = nil
        wgInterfaceListenPort = nil
        wgInterfaceDnsServers = nil
        wgPeerPublicKey = nil
        wgPeerPersistentKeepAlive = nil
        wgPeerEndpoint = nil
    }
    
}
