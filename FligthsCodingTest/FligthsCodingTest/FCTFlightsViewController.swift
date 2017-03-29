//
//  FCTFlightsViewController.swift
//  FligthsCodingTest
//
//  Created by jose humberto partida garduño on 3/28/17.
//  Copyright © 2017 jose humberto partida garduño. All rights reserved.
//

import UIKit

class FCTFlightsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var resultsTableView: UITableView!
    var data:[Any] = []
    let cellIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView()
    {
        self.resultsTableView.register(UINib(nibName:"FCTFlightCellTableViewCell",bundle:nil),forCellReuseIdentifier: cellIdentifier)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FCTFlightCellTableViewCell
        let flight = data[indexPath.row] as! NSDictionary
        let number = flight.value(forKey: "FltId") as! String
        let originAirport = flight.value(forKey: "Orig") as! String
        let arrivalTime = flight.value(forKey: "SchedArrTime") as! String
        let dateTime = getFlightDate(from: arrivalTime)
        let (date,time) = dateTime
        cell.flightNumber.text = number
        cell.originAirport.text = originAirport
        cell.arrivalDate.text = date
        cell.arrivalTime.text = time
        return cell
        
    }
    
    func getFlightDate(from schedArrTime:String) -> (String,String){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let date = dateFormatter.date(from: schedArrTime)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: date!)
        return (String(format:"%02d/%02d/%d",components.month!,components.day!,components.year!),String(format:"%02d:%02d",components.hour!,components.minute!))
        ///let components = NSCalendar.currentCalendar.com
    }
}
