//
//  AppDelegate.swift
//  AppAS
//
//  Created by Juan Delgado on 29/11/18.
//  Copyright © 2018 Juan Delgado. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        preloadData()
        return true
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "AppAS", withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("CoreDataDemo.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func parseCSV (contentsOfURL: NSURL, encoding: String.Encoding) -> [(name:String, detail:String, price: String, image: String)]? {
        
        let delimiter = ","
        var products:[(name:String, detail:String, price: String, image: String)]?
        
        do {
            let content = try String(contentsOf: contentsOfURL as URL, encoding: encoding)
            products = []
            
            let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
            
            for line in lines {
                var values:[String] = []
                if line != "" {
                    if line.range(of: "\"") != nil {
                        var textToScan:String = line
                        var value:NSString?
                        var textScanner:Scanner = Scanner(string: textToScan)
                        while textScanner.string != "" {
                            
                            if (textScanner.string as NSString).substring(to: 1) == "\"" {
                                textScanner.scanLocation += 1
                                textScanner.scanUpTo("\"", into: &value)
                                textScanner.scanLocation += 1
                            } else {
                                textScanner.scanUpTo(delimiter, into: &value)
                            }
                            values.append(value! as String)
                            if textScanner.scanLocation < textScanner.string.count {
                                textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                            } else {
                                textToScan = ""
                            }
                            textScanner = Scanner(string: textToScan)
                        }
                    } else  {
                        values = line.components(separatedBy: delimiter)
                    }
                    let product = (name: values[0], detail: values[1], price: values[2], image: values[3])
                    products?.append(product)
                }
            }
            
        } catch {
            print(error)
        }
        
        return products
    }
    
    func preloadData () {
        guard let url = NSURL(string: "https://docs.google.com/spreadsheets/d/12pBR2w9VyRYqq5xtVlRn9Z-BVhTen9sHrBTMbElmwuQ/export?format=csv") else {
            return
        }
        
        removeData()
        
        if let productsCSV = parseCSV(contentsOfURL: url, encoding: String.Encoding.utf8) {
            for item in productsCSV {
                let product = NSEntityDescription.insertNewObject(forEntityName: "Product", into: managedObjectContext) as! Product
                product.name = item.name
                product.detail = item.detail
                product.price = (item.price as NSString).doubleValue as NSNumber
                product.image = item.image
                
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func removeData () {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        
        do {
            let products = try managedObjectContext.fetch(fetchRequest) as! [Product]
            for product in products {
                managedObjectContext.delete(product)
            }
        } catch {
            print(error)
        }
    }
}

