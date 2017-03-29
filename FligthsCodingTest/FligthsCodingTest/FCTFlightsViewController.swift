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
            let dateTime = getFlightDate(from: arrivalTime)
            let (date,time) = dateTime
            if let entity = FCTStorageManager.sharedInstance.create(entity: "Flight", with: ["number":number,"origin":originAirport,"arrivalDate":date,"arrivalTime":time]){
              objectManagedData.append(entity)
            }
        }
        FCTStorageManager.sharedInstance.save()
        
    }
    /// delegate from TimeManager
    func timeUp() {
        if let tempAirport = currentAirport
        {
            let endpoint = String(format:airportsEndPoint,tempAirport,10,60)
            let getMethod = "GET"
            APIClient.sharedInstance.clientCallWithEndPointUrl(endPoint:endpoint, method: getMethod, dataDictionary:nil, successClosure:{(response:Any?) in
            
                let responseArray = response as! Array<Any>
                DispatchQueue.main.async {
                    guard responseArray.count > 0 else{
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
        cell.arrivalTime.text = flight.arrivalTime
        return cell
        
    }
    
    /// Format the given date to show in the tableview cell
    /// - Returns:
    ///   - A tuple representing the date and time for the given date in format mm/dd/yyyy and HH:mm respectively
    ///
    /// - Parameters:
    ///   - schedArrTime: the date to format and conver to
    func getFlightDate(from schedArrTime:String) -> (String,String){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let date = dateFormatter.date(from: schedArrTime)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: date!)
        return (String(format:"%02d/%02d/%d",components.month!,components.day!,components.year!),String(format:"%02d:%02d",components.hour!,components.minute!))
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
    
    
    
    @IBAction func filterArrivalTime(_ sender: Any) {
        guard objectManagedData.count > 0 else{
            return
        }
        
        let sortedThread = DispatchQueue(label: "sortedThread")
        weak var weakSelf  = self
        sortedThread.async{
            let sortedArray = weakSelf?.objectManagedData.sorted(by: {(item1:NSManagedObject,item2:NSManagedObject) -> Bool in
                if let obj1 = item1 as? Flight, let obj2 = item2 as? Flight{
                    let date1 = weakSelf?.getDateTime(from:String(format:"%@T%@",obj1.arrivalDate!,obj1.arrivalTime!), with: "mm-dd-yyyy'T'HH:mm")
                    let date2 = weakSelf?.getDateTime(from:String(format:"%@T%@",obj2.arrivalDate!,obj2.arrivalTime!), with: "mm-dd-yyyy'T'HH:mm")
                    if let datetemp1 = date1,let datetemp2 = date2{
                        return (datetemp1.compare(datetemp2)) == ComparisonResult.orderedAscending
                    }
                    else{
                        return false
                    }
                    
                }
                return false
                
            })
            weakSelf?.objectManagedData.removeAll()
            if let tempSortedArray = sortedArray{
                weakSelf?.objectManagedData = Array(tempSortedArray)
                DispatchQueue.main.async {
                    weakSelf?.resultsTableView.reloadData()
                }
            }
        }
    }
}
