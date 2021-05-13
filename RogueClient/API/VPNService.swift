//
//  VPNService.swift
//  RogueClient
//
//  Created by Antonio Campos on 5/12/21.
//  Copyright © 2021 Winston Privacy, Inc. All rights reserved.
//

import Foundation
import Ipify
import Alamofire

class VPNService {
    
    static var shared = VPNService()
    
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
    
    func getWiregardInterface(completion: @escaping(Result<WireguardInterface>) -> Void) {
        
        Application.shared.authentication.getAccessToken { accessToken in
            
            let headers: HTTPHeaders = ["Authorization": accessToken]
            
            let keyPair = KeyPair()
            
            self.getIpAddress { (ipAddress) in
                                
                let parameters: [String: Any] = [
                    "ip_address" : ipAddress,
                    "listen_port" : KeyChain.wgInterfaceListenPort ?? Config.wgInterfaceListenPort,
                    "public_key" : keyPair.publicKey ?? "",
                    "server_port": Application.shared.settings.connectionProtocol.port()
                ]
                
                AF.request("http://13.59.81.71:443/api/v1/wg/connect",
                    method: .post,
                    parameters: parameters,
                    encoding: JSONEncoding.default,
                    headers: headers
                ).responseDecodable(of: WireguardInterface.self) { response in
                            
                            switch response.result {
                            
                            case .success(let wireguardInterface):
                                log(info: "getWireguardInterface success \(wireguardInterface)")
                                
                                UserDefaults.shared.set(Date(), forKey: UserDefaults.Key.wgKeyTimestamp)
            
                                KeyChain.wgInterfacePrivateKey = keyPair.privateKey
                                KeyChain.wgInterfacePublicKey = keyPair.publicKey
                                KeyChain.wgInterfaceDnsServers = wireguardInterface.dns
                                KeyChain.wgInterfaceAddresses = wireguardInterface.allowedIps
            
                                KeyChain.wgPeerPublicKey = wireguardInterface.publicKey
                                KeyChain.wgPeerEndpoint = wireguardInterface.endpoint
                                KeyChain.wgPeerPersistentKeepAlive = wireguardInterface.keepAlive
            
                                completion(.success(wireguardInterface))

                            case .failure(let error):
                                log(error: "getWireguardInterface error \(error)")
                                completion(.failure(error))
                            }
                }

            }
            
        }
    }
    
    func getServers(storeInCache: Bool, completion: @escaping (ServersUpdateResult) -> Void) {
        // static let apiServersFile = "/vpn/servers"
//        AF.request("\(Config.WinstonApiUrl)/vpn/servers").responseDecodable(of: VPNServerList.self) { (response) in
//
//        }
        
//        AF.request("\(Config.WinstonApiUrl)/vpn/geolookup").responseDecodable(of: GeoLookup.self) { (response) in
//            completion(response.value)
//        }
    }
    
    
//    func getServersList(storeInCache: Bool, completion: @escaping (ServersUpdateResult) -> Void) {
//        let request = APIRequest(method: .get, path: Config.apiServersFile)
//
//        log(info: "Fetching servers list...")
//
//        APIClient().perform(request) { result in
//            switch result {
//            case .success(let response):
//
//                guard Config.useDebugServers == false else { return }
//
//                if let data = response.body {
//                    let serversList = VPNServerList(withJSONData: data, storeInCache: storeInCache)
//
//                    if serversList.servers.count > 0 {
//                        log(info: "Fetching servers list completed successfully")
//                        completion(.success(serversList))
//                        return
//                    }
//                }
//
//                log(info: "Error updating servers list (probably parsing error)")
//                completion(.error)
//            case .failure:
//                log(info: "Error fetching servers list")
//                completion(.error)
//            }
//        }
//    }
    
    
  

}
