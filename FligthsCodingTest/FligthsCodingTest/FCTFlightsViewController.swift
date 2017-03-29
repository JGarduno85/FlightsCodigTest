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
//        data.sort(by: {(item1:Any,item2:Any) -> Bool in
//            let flight1 = item1 as! NSDictionary
//            let flight2 = item2 as! NSDictionary
//            
//            
//        })
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
        cell.flightNumber.text = number
        cell.originAirport.text = originAirport
        cell.arrivalTime.text = arrivalTime
        return cell
        
    }
}
