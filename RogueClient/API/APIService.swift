//
//  APIService.swift
//  RogueClient
//
//  Created by Antonio Campos on 5/14/21.
//  Copyright © 2021 Winston Privacy, Inc. All rights reserved.
//

import Foundation

class APIService {
    
    
    func getVpnServerError(error: Error, data: Data?, statusCode: Int = 500) -> Error {
        
        let decoder = JSONDecoder()

        if let apiError = try? decoder.decode(VPNServerError.self, from: data!) {
            return NSError(
                domain: "ApiServiceDomain",
                code: statusCode,
                userInfo: [NSLocalizedDescriptionKey : apiError.error]
            )
        }
        
        return error
    }
    
}
