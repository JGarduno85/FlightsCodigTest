//
//  FCTStorageManager.swift
//  FligthsCodingTest
//
//  Created by jose humberto partida garduño on 3/28/17.
//  Copyright © 2017 jose humberto partida garduño. All rights reserved.
//

import Foundation



class FCTStorageManager{
    static let sharedInstance = FCTStorageManager()
    
    private init(){}
    
    
    func create(entity name: String,with properties:Dictionary<String,String>) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        let entityDescription = NSEntityDescription.entity(forEntityName: name,in: managedContext)!
        
        let theEntity = NSManagedObject(entity: entityDescription,
                                      insertInto: managedContext)
        
        
        for (key,value) in properties{
            theEntity.setValue(value, forKey: key)
        }
        save(in:managedContext)
        
    }
    
    func save(in managedContext:NSManagedObjectContext){
        do {
            try managedContext.save()
            //data.append(airport)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

}
