//
//  Config.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Antonio Campos
//  Copyright (c) 2021 Winston Privacy, Inc.
//
//  This file is part of the Rogue iOS app.
//

import UIKit

struct Config {
    
    static let useDebugServers = false
    static let useDebugWireGuardKeyUpgrade = false
    static let minPingCheckInterval: TimeInterval = 10
    static let appGroup = "group.com.winstonprivacy.rogue"
    
//    static let apiServersFile = "/v4/servers.json"
    static let apiServersFile = "/vpn/servers"
    
    // static let apiGeoLookup = "/v4/geo-lookup"
    static let apiSessionNew = "/v4/session/new"
    static let apiSessionStatus = "/v4/session/status"
    static let apiSessionDelete = "/v4/session/delete"
    //static let apiSessionWGKeySet = "/v4/session/wg/set"
    static let apiSessionWGKeySet = "/api/v1/wg/connect"
    static let apiAccountNew = "/v4/account/new"
    static let apiPaymentInitial = "/v4/account/payment/ios/initial"
    static let apiPaymentAdd = "/v4/account/payment/ios/add"
    static let apiPaymentAddLegacy = "/v2/mobile/ios/subscription-purchased"
    static let apiPaymentRestore = "/v4/account/payment/ios/restore"
    
    static let urlTypeLogin = "login"
    static let urlTypeConnect = "connect"
    static let urlTypeDisconnect = "disconnect"
    
    static let ikev2TunnelTitle = "IVPN IKEv2"
    static let openvpnTunnelProvider = "com.winstonprivacy.rogue.openvpn-tunnel-provider"
    static let openvpnTunnelTitle = "IVPN OpenVPN"
    static let wireguardTunnelProvider = "com.winstonprivacy.rogue.wireguard-tunnel-provider"
    // static let wireguardTunnelTitle = "IVPN WireGuard"
    static let wireguardTunnelTitle = "Rogue VPN"
    
    // Files and Directories
    static let serversListCacheFileName = "servers_cache1.json"
    static let openVPNLogFile = "OpenVPNLogs.txt"
    
    // Contact Support web page
    static let contactSupportMail = "support@winstonprivacy.com"
    static let contactSupportPage = "mailto:support@winstonprivacy.com"
    
    static let serviceStatusRefreshMaxIntervalSeconds: TimeInterval = 30
    static let stableVPNStatusInterval: TimeInterval = 0.5
    
    static let defaultProtocol = ConnectionSettings.ipsec
    
    static let supportedProtocols = [
        ConnectionSettings.wireguard(.udp, 2049),
        ConnectionSettings.wireguard(.udp, 2050),
        ConnectionSettings.wireguard(.udp, 53),
        ConnectionSettings.wireguard(.udp, 1194),
        ConnectionSettings.wireguard(.udp, 30587),
        ConnectionSettings.wireguard(.udp, 41893),
        ConnectionSettings.wireguard(.udp, 48574),
        ConnectionSettings.wireguard(.udp, 58237)
    ]
    
    static let wgPeerAllowedIPs = "0.0.0.0/0, ::/0"
    static let wgPeerPersistentKeepalive: Int32 = 25
    static let wgInterfaceListenPort = 51820
    static let wgKeyExpirationDays = 30
    static let wgKeyRegenerationRate = 1
    
    static var Environment: String {
        return value(for: "Environment")
    }
    
    static var ApiHostName: String {
        return value(for: "ApiHostName")
    }
    
    static var WinstonApiUrl: String {
        return value(for: "WinstonApiUrl")
    }
    
    static var IvpnApiUrl: String {
        return value(for: "IvpnApiUrl")
    }
    
    static var TlsHostName: String {
        return value(for: "TlsHostName")
    }
    
    // MARK: ENV .xcconfig parser
    
    static func value<T>(for key: String) -> T {
        guard let value = Bundle.main.infoDictionary?[key] as? T else {
            fatalError("Invalid or missing Info.plist key: \(key)")
        }
        
        return value
    }
    
}
