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
    
    fileprivate var flightsViewOn:Bool = false
    
    var goToFlights:Bool{
        get{
            return flightsViewOn
        }
        set{
            flightsViewOn = newValue
        }
    }
    
    func saveUserDefault(forkey key:String,value:Any){
        let userDefault = UserDefaults()
        userDefault.setValue(value, forKey: key)
        userDefault.synchronize()
    }
    
    func getUserDefault(forkey key:String) -> Any?{
        let userDefault = UserDefaults()
        if let value = userDefault.value(forKey: key){
            return value
        }else{
            return nil
        }
    }
    
    func deleteUserDefault(forKey key:String){
        let userDefault = UserDefaults()
        userDefault.removeObject(forKey: key)
    }
    
    
    func create(entity name: String,with properties:Dictionary<String,String>) -> NSManagedObject? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        let entityDescription = NSEntityDescription.entity(forEntityName: name,in: managedContext)!
        
        let theEntity = NSManagedObject(entity: entityDescription,
                                      insertInto: managedContext)
        
        
        for (key,value) in properties{
            theEntity.setValue(value, forKey: key)
        }

        
        return theEntity
        
    }
    
    func delete(entities name:String){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let objects = fetchEntities(name: name)
        if let tempObjs = objects{
            for item in tempObjs{
                managedContext.delete(item)
            }
            save()
        }

    }
    
    
    func fetchEntities(name:String) -> [NSManagedObject]?{
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName:name)
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            return data
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func save(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext

        do {
            try managedContext.save()
            //data.append(airport)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

}
