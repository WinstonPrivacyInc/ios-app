//
//  Authentication.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/9/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

//
//  Authentication.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-10-09.
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
    
    func getAccessKey(completion: @escaping (String) -> Void) {
        Amplify.Auth.fetchAuthSession { result in
            
            var accessKey = ""
            
            do {
                let session = try result.get()

                // Get aws credentials
                if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                    let credentials = try awsCredentialsProvider.getAWSCredentials().get()
                    print("Access key - \(credentials.accessKey) ")
                    accessKey = credentials.accessKey
                }
            } catch {
                print("Fetch auth session failed with error - \(error)")
            }
            
            completion(accessKey)
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
