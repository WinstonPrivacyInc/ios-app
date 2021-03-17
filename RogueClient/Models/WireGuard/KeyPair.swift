//
//  KeyPair.swift
//  RogueClient
//
//  Created by Antonio Campos on 3/17/21.
//  Copyright © 2021 Winston Privacy. All rights reserved.
//

import Foundation

struct KeyPair {
    
    var privateKey: String?
    var publicKey: String?
    
    
    init() {
        self.privateKey = self.generatePrivateKey()
        self.publicKey = self.generatePublicKey()
    }
    
    private func generatePrivateKey() -> String {
        var privateKey = Data(count: 32)
        privateKey.withUnsafeMutableUInt8Bytes { mutableBytes in
            curve25519_generate_private_key(mutableBytes)
        }
        
        return privateKey.base64EncodedString()
    }
    
    private func generatePublicKey() -> String {
        if let privateKeyString = self.privateKey, let privateKey = Data(base64Encoded: privateKeyString) {
            var publicKey = Data(count: 32)
            privateKey.withUnsafeUInt8Bytes { privateKeyBytes in
                publicKey.withUnsafeMutableUInt8Bytes { mutableBytes in
                    curve25519_derive_public_key(mutableBytes, privateKeyBytes)
                }
            }
            return publicKey.base64EncodedString()
        }
        
        return ""
    }
    
}
