//
//  FCTSearchAirportViewController.swift
//  FligthsCodingTest
//
//  Created by jose humberto partida garduño on 3/28/17.
//  Copyright © 2017 jose humberto partida garduño. All rights reserved.
//

import UIKit


class FCTSearchAirportViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBarAirports: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    var searchActive : Bool = false
    var data:[NSManagedObject] = []

    let cellIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupSearchBar()
        setupTableView()

    }
    
    func setupSearchBar(){
        searchBarAirports.delegate = self
    }
    
    func setupTableView(){
        
        self.resultsTableView.register(UINib(nibName:"TableViewCell",bundle:nil), forCellReuseIdentifier: cellIdentifier)
        
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName:airportEntity)
        
        do {
            data = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return historySectionTitle
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TableViewCell
        let airport = data[indexPath.row]
        let code = airport.value(forKey:airportCode)
        cell.airportName.text = code as! String?
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let code = searchBar.text{
            if !code.isEmpty{
                makeFlightSearch(forAirport: code)
            }
        }
    }

    
    func makeFlightSearch(forAirport name:String){
        guard !name.isEmpty else{
            return
        }
        
        let endpoint = String(format:airportsEndPoint,name,10,120)
        let getMethod = "GET"
        APIClient.sharedInstance.clientCallWithEndPointUrl(endPoint:endpoint, method: getMethod, dataDictionary:nil, successClosure:{(response:Any?) in
            DispatchQueue.main.async {
                //self.responseText.text = response.debugDescription
                //print(response)
                
            }
        }, failureClosure: {(error:Error) in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "It appears there's a problem with the server", preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            }
        })
        
       // FCTStorageManager.sharedInstance.create(entity: airportEntity, with: [airportCode:name])
        //save(code: name)
    }
    
    
   /* func save(code: String) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Airport",
                                       in: managedContext)!
        
        let airport = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        
       airport.setValue(code, forKeyPath: "code")
        
        do {
            try managedContext.save()
            data.append(airport)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }*/

}
