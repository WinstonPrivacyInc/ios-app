//
//  Authentication.swift
//  Rogue iOS
//
//  Created by Fedir Nepyyvoda on 10/9/16.
//  Copyright © 2016 Winston Privacy. All rights reserved.
//

//
//  Authentication.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Fedir Nepyyvoda on 2016-10-09.
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

import Foundation
import Amplify
import AWSPluginsCore
// Authentication class is responsible for securely storing and retrieving of login credentials
// It does not perform any authentication and just managing the informatino supplied

class Authentication {
    
    // MARK: - Properties -
    
    var isLoggedIn: Bool {
        let username = getStoredUsername()
        let sessionToken = getStoredSessionToken()
        return !username.isEmpty || !sessionToken.isEmpty
    }
    
    // MARK: - Methods -
    
    func logIn(session: Session) {
        guard session.token != nil, session.vpnUsername != nil, session.vpnPassword != nil else { return }
        
        KeyChain.save(session: session)
    }
    
    func isSignedIn(completion: @escaping (Bool) -> Void) {
        _ = Amplify.Auth.fetchAuthSession { result in
            switch result {
            case .success(let session):
                log(info: "Is user signed in - \(session.isSignedIn)")
                completion(session.isSignedIn)
            case .failure(let error):
                print("Fetch session failed with error \(error)")
                completion(false)
            }
        }
    }
    
    func getAccessToken(completion: @escaping (String) -> Void) {
        Amplify.Auth.fetchAuthSession { result in
            
            var accessToken = ""
            
            do {
                let session = try result.get()
                
                if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                    let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                    accessToken = tokens.accessToken
                }
            } catch {
                log(info: "Failed to get access token with error - \(error)")
            }
            
            completion(accessToken)
        }
    }
    
    func logOut() {
        KeyChain.clearAll()
        FileSystemManager.clearSession()
        StorageManager.clearSession()
        UserDefaults.clearSession()
        Application.shared.clearSession()
        
        Amplify.Auth.signOut() { result in
                switch result {
                case .success:
                    print("Successfully signed out")
                case .failure(let error):
                    print("Sign out failed with error \(error)")
                }
            }
    }
    
    func removeStoredCredentials() {
        KeyChain.username = nil
        
        log(info: "Credentials removed from Key Chain")
    }
    
    func getStoredUsername() -> String {
        log(info: "Username read from Key Chain")
        
        return KeyChain.username ?? ""
    }
    
    func getStoredSessionToken() -> String {
        log(info: "Session token read from Key Chain")
        
        return KeyChain.sessionToken ?? ""
    }
    
}
