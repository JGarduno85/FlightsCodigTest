//
//  FCTFlightsViewController.swift
//  FligthsCodingTest
//
//  Created by jose humberto partida garduño on 3/28/17.
//  Copyright © 2017 jose humberto partida garduño. All rights reserved.
//

import UIKit

class FCTFlightsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,TimeManagerDelegate {

    @IBOutlet weak var resultsTableView: UITableView!
    var data:[Any] = []
    var objectManagedData:[NSManagedObject] = []
    let cellIdentifier = "Cell"
    var openFromDelegate = false
    var timeManager:TimeManager?
    var currentAirport:String?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,from isAppDelegate:Bool){
        self.init(nibName: nibNameOrNil,bundle: nibBundleOrNil)
        self.openFromDelegate = isAppDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        // Do any additional setup after loading the view.
        FCTStorageManager.sharedInstance.goToFlights = true
        if self.openFromDelegate{
            if let fetchedData = FCTStorageManager.sharedInstance.fetchEntities(name: "Flight"){
                objectManagedData = fetchedData
            }
        }
        self.timeManager = TimeManager()
        self.timeManager?.delegate = self
        timeManager?.starTimer()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.openFromDelegate{
            self.openFromDelegate = false
            let tempCurrentAirport = FCTStorageManager.sharedInstance.getUserDefault(forkey: "currentAirport")
            self.currentAirport = tempCurrentAirport as? String
            self.resultsTableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timeManager?.stopTimer()
        timeManager?.delegate = nil
        timeManager = nil
        FCTStorageManager.sharedInstance.saveUserDefault(forkey: "currentAirport", value: currentAirport ?? "")
    }
    
    /// Create the core data entities from the json rettrieve and save the context
    func saveData(){
        
        for item in data{
            let flight = item as! NSDictionary
            let number = flight.value(forKey: "FltId") as! String
            let originAirport = flight.value(forKey: "Orig") as! String
            let arrivalTime = flight.value(forKey: "SchedArrTime") as! String
            if let entity = FCTStorageManager.sharedInstance.create(entity: "Flight", with: ["number":number,"origin":originAirport,"arrivalDate":arrivalTime,"arrivalTime":arrivalTime]){
              objectManagedData.append(entity)
            }
        }
        
        objectManagedData = filterArrivalTime()
        FCTStorageManager.sharedInstance.save()
        
    }
    /// delegate from TimeManager
    func timeUp() {
        if let tempAirport = currentAirport
        {
            let endpoint = String(format:airportsEndPoint,tempAirport,10,60)
            let getMethod = "GET"
            MBProgressHUD.showAdded(to: self.view, animated: true)
            APIClient.sharedInstance.clientCallWithEndPointUrl(endPoint:endpoint, method: getMethod, dataDictionary:nil, successClosure:{(response:Any?) in
            
                MBProgressHUD.hide(for: self.view, animated: true)
                let responseArray = response as! Array<Any>
                DispatchQueue.main.async {
                    guard responseArray.count > 0 else{
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
                        _ = self.navigationController?.popViewController(animated: true)
                        return
                    }

                    
                self.data = responseArray
                self.saveData()
                self.resultsTableView.reloadData()
                self.timeManager?.starTimer()

            }
            }, failureClosure: {(error:Error) in

            })
        }
    }
    
    /// Setup the navigationBar data
    func setupNavigationBar(){
        self.navigationItem.title = "Flights schedules"
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action:#selector(backButtonAction))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    /// Setup the tableview data
    func setupTableView()
    {
        self.resultsTableView.register(UINib(nibName:"FCTFlightCellTableViewCell",bundle:nil),forCellReuseIdentifier: cellIdentifier)
        
    }
    
    ///Used to detect when the user press the back button from the navigationBar and procced to delete the objects stored on CoreData.
    func backButtonAction(){
        FCTStorageManager.sharedInstance.delete(entities: "Flight")
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectManagedData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FCTFlightCellTableViewCell
        let flight = objectManagedData[indexPath.row] as! Flight
        cell.flightNumber.text = flight.number
        cell.originAirport.text = flight.origin
        cell.arrivalDate.text = flight.arrivalDate
        return cell
        
    }
    
    
    
    /// transform a given string date and time into a date
    /// - Returns:
    ///   - a date from the string given
    ///
    /// - Parameters:
    ///   - dateString: the date string to format
    ///   - formatDate: the dateformat wanted
    func getDateTime(from dateString:String,with formatDate:String) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatDate
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let date = dateFormatter.date(from: dateString)
        return date
    }
    
    
    
   func filterArrivalTime()  -> [NSManagedObject]{
        guard objectManagedData.count > 0 else{
            return objectManagedData
        }
    
        MBProgressHUD.showAdded(to: self.view, animated: true)
            let sortedArray = objectManagedData.sorted(by: {(item1:NSManagedObject,item2:NSManagedObject) -> Bool in
                if let obj1 = item1 as? Flight, let obj2 = item2 as? Flight, let arrivalDat1 = obj1.arrivalDate,let arrivalDat2 = obj2.arrivalDate{
                    
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
                    let date1 = dateFormatter.date(from:arrivalDat1)
                    let date2 = dateFormatter.date(from:arrivalDat2)
                    if let datetemp1 = date1,let datetemp2 = date2{
                        if(datetemp1.compare(datetemp2)) == ComparisonResult.orderedAscending{
                            return true
                        }else{
                            return false
                        }
                    }
                    else{
                        return false
                    }
                    
                }
                return false
                
            })
        MBProgressHUD.hide(for: self.view, animated: true)
        return sortedArray
    }
}
