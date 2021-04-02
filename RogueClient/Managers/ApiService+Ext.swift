//
//  ApiService+Ext.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2019-08-08.
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

import UIKit

extension ApiService {
    
    // MARK: - Methods -
    
    func getServersList(storeInCache: Bool, completion: @escaping (ServersUpdateResult) -> Void) {
        let request = APIRequest(method: .get, path: Config.apiServersFile)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        log(info: "Fetching servers list...")
        
        APIClient().perform(request) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                guard Config.useDebugServers == false else { return }
                
                if let data = response.body {
                    let serversList = VPNServerList(withJSONData: data, storeInCache: storeInCache)
                    
                    if serversList.servers.count > 0 {
                        log(info: "Fetching servers list completed successfully")
                        completion(.success(serversList))
                        return
                    }
                }
                
                log(info: "Error updating servers list (probably parsing error)")
                completion(.error)
            case .failure:
                log(info: "Error fetching servers list")
                completion(.error)
            }
        }
    }
    
}
