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
    
    func createAccount(completion: @escaping (Result<Account>) -> Void) {
        
        Application.shared.authentication.getAccessToken { accessToken in
            
            let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
            
            AF.request("\(Config.WinstonApiUrl)/accounts", method: .post, headers: headers)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: Account.self) { response in
                                        
                    switch response.result {
                    case .success(let account):
                        log(info: "Account created \(String(describing: account.accountId))")
                        completion(.success(account))
                    
                    case .failure(let error):
                        log(error: "Error created account \(error)")
                        completion(.failure(error))
                    }
                }
        }
    }
    
}
