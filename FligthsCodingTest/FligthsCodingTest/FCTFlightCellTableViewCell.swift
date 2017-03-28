//
//  FCTFlightCellTableViewCell.swift
//  FligthsCodingTest
//
//  Created by jose humberto partida garduño on 3/28/17.
//  Copyright © 2017 jose humberto partida garduño. All rights reserved.
//

import UIKit

class FCTFlightCellTableViewCell: UITableViewCell {

    @IBOutlet weak var flightNumber: UILabel!
    @IBOutlet weak var originAirport: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
