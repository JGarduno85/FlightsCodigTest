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
    ///    * aiport code: three letters airport code
    ///    * minutes past: minutes in the past to query
    ///    * minutes future: minutes in the future to query
    ///
    ///     urlbase/1/airports/SEA/flights/10/120
   let airportsEndPoint = "/1/airports/%@/flights/%d/%d"






    /// CoreData Entities
    /// Airport
    let airportEntity = "Airport"
    let airportCode = "code"



    /// SearchAirport tableView
    ///
    let historySectionTitle = "History"

    /// Request 
    /// Authorization values
    let authorizationHeader = "Authorization"
    let authorizationValue = "Basic YWFnZTQxNDAxMjgwODYyNDk3NWFiYWNhZjlhNjZjMDRlMWY6ODYyYTk0NTFhYjliNGY1M2EwZWJiOWI2ZWQ1ZjYwOGM="
