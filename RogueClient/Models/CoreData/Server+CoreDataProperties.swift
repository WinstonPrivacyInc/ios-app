//
//  Server+CoreDataProperties.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2019-02-19.
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
import CoreData

extension Server {
    
    @NSManaged public var gateway: String?
    @NSManaged public var isFastestEnabled: Bool
    
    @nonobjc public class func fetchRequest(gateway: String = "", isFastestEnabled: Bool = false) -> NSFetchRequest<Server> {
        let fetchRequest = NSFetchRequest<Server>(entityName: "Server")
        var filters = [NSPredicate]()
        
        if !gateway.isEmpty {
            filters.append(NSPredicate(format: "gateway == %@", gateway.replacingOccurrences(of: ".wg.", with: ".gw.")))
        }
        
        if isFastestEnabled {
            filters.append(NSPredicate(format: "isFastestEnabled == %@", NSNumber(value: isFastestEnabled)))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filters)
        
        return fetchRequest
    }

}
