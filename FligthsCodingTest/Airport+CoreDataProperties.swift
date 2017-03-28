//
//  Airport+CoreDataProperties.swift
//  
//
//  Created by jose humberto partida garduño on 3/28/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Airport {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Airport> {
        return NSFetchRequest<Airport>(entityName: "Airport");
    }

    @NSManaged public var code: String?

}
