//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by akhil mantha on 23/08/18.
//  Copyright © 2018 akhil mantha. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    convenience init(url:String,order:Int16, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.url = url
            self.order = order
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
