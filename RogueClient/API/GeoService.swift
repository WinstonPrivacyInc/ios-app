//
//  GeoService.swift
//  RogueClient
//
//  Created by Antonio Campos on 5/4/21.
//  Copyright © 2021 Winston Privacy, Inc. All rights reserved.
//

import Foundation
import Alamofire

class GeoService {
    
    static var shared = GeoService()
    
    func geoLookUp(completion: @escaping (GeoLookup?) -> Void) {
        AF.request("\(Config.IvpnApiUrl)/v4/geo-lookup").responseDecodable(of: GeoLookup.self) { (response) in
            completion(response.value)
        }
    }
    
}
