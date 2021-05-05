//
//  AccountService.swift
//  RogueClient
//
//  Created by Antonio Campos on 5/4/21.
//  Copyright © 2021 Winston Privacy, Inc. All rights reserved.
//

import Foundation
import Alamofire

class AccountService {
    
    static var shared = AccountService()
    
    func createAccount(completion: @escaping () -> Void) {
        
        Application.shared.authentication.getAccessToken { accessToken in
            
            let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
            
            AF.request("\(Config.WinstonApiUrl)/accounts", method: .post, headers: headers).responseJSON { (data) in
                completion()
            }
            
        }
    }
    
}
