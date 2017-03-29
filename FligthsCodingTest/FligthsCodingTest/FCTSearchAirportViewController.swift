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
    
    var data:[NSManagedObject] = []

    let cellIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Flights search"
        
        setupSearchBar()
        setupTableView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FCTStorageManager.sharedInstance.getUserDefault(forkey: "goToFlightsView") != nil
        {
            FCTStorageManager.sharedInstance.deleteUserDefault(forKey:"goToFlightsView")
            let flightsViewController = FCTFlightsViewController()
            flightsViewController.openFromDelegate = true
            self.navigationController?.pushViewController(flightsViewController, animated: true)
        }
        FCTStorageManager.sharedInstance.goToFlights = false
    }
    
    /// Setup the searchbar data
    func setupSearchBar(){
        searchBarAirports.autocapitalizationType = .allCharacters
        searchBarAirports.delegate = self
        searchBarAirports.tintColor = UIColor.darkGray
    }
    
    /// Setup the tableview data
    func setupTableView(){
        
        self.resultsTableView.register(UINib(nibName:"TableViewCell",bundle:nil), forCellReuseIdentifier: cellIdentifier)
        data = FCTStorageManager.sharedInstance.fetchEntities(name: airportEntity) ?? []
        
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
        let airport = data[indexPath.row]
        let code = airport.value(forKey: airportCode) as! String
        makeFlightSearch(forAirport: code)
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text.rangeOfCharacter(from:CharacterSet.letters) != nil) || text.isEmpty || text == "\n"{
            return true
        }
        else {
            return false
        }
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        if let code = searchBar.text{
            if !code.isEmpty{
                makeFlightSearch(forAirport: code)
            }
        }
    }


    /// Make the request to the API using the ClientAPI
    ///
    /// - Parameters:
    ///   - name:airport 3 digits code
    func makeFlightSearch(forAirport name:String){
        guard !name.isEmpty else{
            return
        }
        
        let endpoint = String(format:airportsEndPoint,name,10,60)
        let getMethod = "GET"
        MBProgressHUD.showAdded(to: self.view, animated: true)
        APIClient.sharedInstance.clientCallWithEndPointUrl(endPoint:endpoint, method: getMethod, dataDictionary:nil, successClosure:{(response:Any?) in
            
            let responseArray = response as! Array<Any>
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                
                guard responseArray.count > 0 else{
                    let alert = UIAlertController(title: "Message", message: "The search doesn't retrieve any result, try with another search criteria", preferredStyle: UIAlertControllerStyle.alert)
                    let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                var now = Date();
                var nowComponents = DateComponents()
                let calendar = Calendar.current
                nowComponents.year = Calendar.current.component(.year, from: now)
                nowComponents.month = Calendar.current.component(.month, from: now)
                nowComponents.day = Calendar.current.component(.day, from: now)
                nowComponents.hour = Calendar.current.component(.hour, from: now)
                nowComponents.minute = Calendar.current.component(.minute, from: now)
                nowComponents.second = Calendar.current.component(.second, from: now)
                nowComponents.timeZone = TimeZone(abbreviation: "GMT")!
                now = calendar.date(from: nowComponents)!
                
                
                let arrayFiltered =  responseArray.filter({(item:Any)->(Bool) in
                   
                    let itemDict = item as! Dictionary<String,Any>
                    let schedArrTime =  itemDict["SchedArrTime"] as! String
                    let schedArrDate = self.getDateTime(from: schedArrTime, with: "yyyy-MM-dd'T'HH:mm:ss")
                    
                    if ((schedArrDate?.compare(now)) != nil){
                        let value = schedArrDate?.timeIntervalSince(now)
                        let timeDifference = Int(value!) / 60
                        if timeDifference > 0 && timeDifference < 59
                        {
                            return true
                        }
                        else{
                            return false
                        }
                    }
                    
                    return false
                    
                })
                if arrayFiltered.count == 0
                {
                    let alert = UIAlertController(title: "Message", message: "The data to show doesn't meet the criteria of 10 minutes before and 1 hour after your local time", preferredStyle: UIAlertControllerStyle.alert)
                    let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let flightsViewController = FCTFlightsViewController()
                flightsViewController.data = arrayFiltered
                flightsViewController.currentAirport = name
                flightsViewController.saveData()
                self.navigationController?.pushViewController(flightsViewController, animated: true)
                let airportArray =  self.data.filter({(aManagedObject:NSManagedObject) -> (Bool) in
                    let airport = aManagedObject as! Airport
                    return airport.code == name
                })
                //the airport is not repeated in the history so we add it
                if airportArray.count == 0
                {
                    if let entity = FCTStorageManager.sharedInstance.create(entity: airportEntity, with: [airportCode:name]){
                        FCTStorageManager.sharedInstance.save()
                        self.data.append(entity)
                        self.resultsTableView.reloadData()
                    }
                }
            }
        }, failureClosure: {(error:Error) in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                let alert = UIAlertController(title: "Error", message: "Comunication problem with the server", preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func getDateTime(from dateString:String,with formatDate:String) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatDate
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let date = dateFormatter.date(from: dateString)
        return date
    }

}
