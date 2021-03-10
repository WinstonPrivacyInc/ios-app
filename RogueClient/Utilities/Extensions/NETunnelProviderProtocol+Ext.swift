//
//  NETunnelProviderProtocol+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-06-12.
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
import NetworkExtension
import TunnelKit

extension NETunnelProviderProtocol {
    
    // MARK: OpenVPN
    
    static func makeOpenVPNProtocol(settings: ConnectionSettings, accessDetails: AccessDetails) -> NETunnelProviderProtocol {
        var username = accessDetails.username
        
        if UserDefaults.shared.isMultiHop && Application.shared.serviceStatus.isEnabled(capability: .multihop) {
            username += "@\(UserDefaults.shared.exitServerLocation)"
        }
        
        let port = UInt16(settings.port())
        let socketType: SocketType = settings.protocolType() == "TCP" ? .tcp : .udp
        let credentials = OpenVPN.Credentials(username, KeyChain.vpnPassword ?? "")
        let staticKey = OpenVPN.StaticKey.init(file: OpenVPNConf.tlsAuth, direction: OpenVPN.StaticKey.Direction.client)
        
        var sessionBuilder = OpenVPN.ConfigurationBuilder()
        sessionBuilder.ca = OpenVPN.CryptoContainer(pem: OpenVPNConf.caCert)
        sessionBuilder.cipher = .aes256cbc
        sessionBuilder.compressionFraming = .disabled
        sessionBuilder.endpointProtocols = [EndpointProtocol(socketType, port)]
        sessionBuilder.hostname = accessDetails.ipAddresses.randomElement() ?? accessDetails.serverAddress
        sessionBuilder.tlsWrap = OpenVPN.TLSWrap.init(strategy: .auth, key: staticKey!)
        
        if let dnsServers = openVPNdnsServers(), dnsServers != [""] {
            sessionBuilder.dnsServers = dnsServers
        }
        
        var builder = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())
        builder.shouldDebug = true
        builder.debugLogFormat = "$Dyyyy-MMM-dd HH:mm:ss$d $L $M"
        builder.masksPrivateData = true
        
        let openVPNconfiguration = builder.build()
        let configuration = try! openVPNconfiguration.generatedTunnelProtocol(
            withBundleIdentifier: Config.openvpnTunnelProvider,
            appGroup: Config.appGroup,
            credentials: credentials
        )
        configuration.disconnectOnSleep = !UserDefaults.shared.keepAlive
        
        return configuration
    }
    
    static func openVPNdnsServers() -> [String]? {
        if UserDefaults.shared.isAntiTracker {
            if UserDefaults.shared.isAntiTrackerHardcore {
                if UserDefaults.shared.isMultiHop && !UserDefaults.shared.antiTrackerHardcoreDNSMultiHop.isEmpty {
                    return [UserDefaults.shared.antiTrackerHardcoreDNSMultiHop]
                } else if !UserDefaults.shared.antiTrackerHardcoreDNS.isEmpty {
                    return [UserDefaults.shared.antiTrackerHardcoreDNS]
                }
            } else {
                if UserDefaults.shared.isMultiHop && !UserDefaults.shared.antiTrackerDNSMultiHop.isEmpty {
                    return [UserDefaults.shared.antiTrackerDNSMultiHop]
                } else if !UserDefaults.shared.antiTrackerDNS.isEmpty {
                    return [UserDefaults.shared.antiTrackerDNS]
                }
            }
        } else if UserDefaults.shared.isCustomDNS && !UserDefaults.shared.customDNS.isEmpty {
            return [UserDefaults.shared.customDNS]
        }
        
        return nil
    }
    
    // MARK: WireGuard
    
    static func makeWireGuardProtocol(settings: ConnectionSettings) -> NETunnelProviderProtocol {
        guard var hostServer = Application.shared.settings.selectedServer.hosts.randomElement() else {
            return NETunnelProviderProtocol()
        }
        
        // override with winston for testing
        hostServer.host = "172.31.38.97";
        hostServer.publicKey = "SJue4OvxWi4EwGkGZ5vKNb61hU4akFm1cV65tNcfyGU=";
        
        
        // this is the server info
        let peer = Peer(
            publicKey: hostServer.publicKey,
            allowedIPs: "0.0.0.0/0, ::/0", //Config.wgPeerAllowedIPs, // 0.0.0.0/0 basically anything
//            allowedIPs: "0.0.0.0/0", //Config.wgPeerAllowedIPs, // 0.0.0.0/0 basically anything
            endpoint: "13.59.81.71:80", // Peer.endpoint(host: hostServer.host, port: settings.port()),
            persistentKeepalive: 15 // Config.wgPeerPersistentKeepalive // 25 in config
        )
        
        // this is my info
        let interface = Interface(
            addresses: KeyChain.wgIpAddress, //"192.168.0.6/32", 
            listenPort: 2049, //Config.wgInterfaceListenPort,
            privateKey: KeyChain.wgPrivateKey, // "QZqecs9M2Cj535Pky7l8VbWjRT8mADoxD3N+ilHCXHs="
            dns: "1.1.1.1"// hostServer.localIPAddress()
        )
        
        print("Interface public key \(String(describing: interface.publicKey))")
        
        
        let tunnel = Tunnel(
            tunnelIdentifier: UIDevice.uuidString(),
            title: Config.wireguardTunnelTitle,
            interface: interface,
            peers: [peer]
        )
        
        let configuration = NETunnelProviderProtocol()
        configuration.providerBundleIdentifier = Config.wireguardTunnelProvider
        configuration.serverAddress = peer.endpoint
        configuration.providerConfiguration = tunnel.generateProviderConfiguration()
        configuration.disconnectOnSleep = !UserDefaults.shared.keepAlive
        
        return configuration
    }
    
}
