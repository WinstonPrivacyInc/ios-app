//
//  Data+Ext.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2019-09-03.
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

extension Data {
    
    func withUnsafeUInt8Bytes<R>(_ body: (UnsafePointer<UInt8>) -> R) -> R {
        return self.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> R in
            let bytes = ptr.bindMemory(to: UInt8.self)
            return body(bytes.baseAddress!) // might crash if self.count == 0
        }
    }
    
    mutating func withUnsafeMutableUInt8Bytes<R>(_ body: (UnsafeMutablePointer<UInt8>) -> R) -> R {
        return self.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) -> R in
            let bytes = ptr.bindMemory(to: UInt8.self)
            return body(bytes.baseAddress!) // might crash if self.count == 0
        }
    }
    
}
