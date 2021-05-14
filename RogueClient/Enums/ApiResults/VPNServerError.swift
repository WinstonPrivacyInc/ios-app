//
//  VPNServerError.swift
//  RogueClient
//
//  Created by Antonio Campos on 5/14/21.
//  Copyright © 2021 Winston Privacy, Inc. All rights reserved.
//

import Foundation

class VPNServerError: Decodable {
    
    let error: String
    
    enum CodingKeys: String, CodingKey {
        case error
    }
}
