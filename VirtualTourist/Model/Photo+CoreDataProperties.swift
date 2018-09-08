//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by akhil mantha on 23/08/18.
//  Copyright © 2018 akhil mantha. All rights reserved.
//

import Foundation
import CoreData


extension Photo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }
    
    @NSManaged public var imageData: Data?
    @NSManaged public var url: String?
    @NSManaged public var order: Int16
    @NSManaged public var pin: Pin?
    
}
