//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by akhil mantha on 23/08/18.
//  Copyright © 2018 akhil mantha. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    
    convenience init(pinAnnotation:PinAnnotation, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = pinAnnotation.coordinate.latitude
            self.longitude = pinAnnotation.coordinate.longitude
            self.createdAt = Date()
            
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
