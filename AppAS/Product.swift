//
//  Product.swift
//  AppAS
//
//  Created by Juan Delgado on 29/11/18.
//  Copyright © 2018 Juan Delgado. All rights reserved.
//

import Foundation
import CoreData

class Product: NSManagedObject {
    @NSManaged var name:String?
    @NSManaged var detail:String?
    @NSManaged var price:NSNumber?
    @NSManaged var image:String?
}
