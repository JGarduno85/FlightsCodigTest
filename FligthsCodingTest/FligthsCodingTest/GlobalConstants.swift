//
//  GlobalConstants.swift
//  FligthsCodingTest
//
//  Created by jose humberto partida garduño on 3/28/17.
//  Copyright © 2017 jose humberto partida garduño. All rights reserved.
//
//
//
import Foundation

/// Define the url endpoint for request flights using airport's code
///
///    * urlbase: url defined in the user defined field in build settings
///    * aiport code: three letters airport code
///    * minutes past: minutes in the past to query
///    * minutes future: minutes in the future to query
///
///     urlbase/1/airports/SEA/flights/10/120
let airportsEndPoint = "%@/1/airports/{airport code}/flights/{minutes past}/{minutes future}"
