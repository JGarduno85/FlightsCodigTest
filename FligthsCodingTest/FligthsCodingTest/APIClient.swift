//
//  APIClient.swift
//  FligthsCodingTest
//
//  Created by jose humberto partida garduño on 3/28/17.
//  Copyright © 2017 jose humberto partida garduño. All rights reserved.
//

import Foundation



/// Define the client which does the request and response
class APIClient{
    
    /// base url retrieve from the userdefaults
    var baseUrlString:String? = Bundle.main.infoDictionary?["WebServicesBaseURLKey"] as? String
    /// class signleton
    static let sharedInstance = APIClient()
    
    /// AFNetworking session manager
    private var afthttpSessionManager:AFHTTPSessionManager?
    
    
    
    private init(){
        createSessionManager()
    }
    
    /// create the AFTNetworking client
    private func createSessionManager(){
        let baseUrl = URL(string:baseUrlString!)
        afthttpSessionManager = AFHTTPSessionManager(baseURL: baseUrl)
    }
    
    
    /// call the webservice
    /// - Parameters:
    ///   - endPoint: web service endpoint to use
    ///   - dataDictionary: web service parameters
    ///   - successClosure: closure used to catch the retrieve data
    ///   - failureClosure: closure used to catch the data if the server retrieve an error
    public func clientCallWithEndPointUrl(endPoint:String,method:String,dataDictionary:Dictionary<String,String>?,successClosure:@escaping (Any?) -> (Void),failureClosure:@escaping (Error) -> (Void)){
        
        afthttpSessionManager?.requestSerializer = AFJSONRequestSerializer()
        afthttpSessionManager?.responseSerializer = AFJSONResponseSerializer()
        
        
        
        
        _ = afthttpSessionManager?.get(endPoint, parameters: dataDictionary, progress:{ (progress:Progress) in
            
            
            
        }, success:{(task:URLSessionDataTask?,response:Any?) in
            let responseString = response as? Dictionary<String,Any>
            if responseString != nil{
                successClosure(response)
            }else{
                successClosure(nil)
            }
            
        }, failure:{ (task:URLSessionDataTask?,error:Error) in
            failureClosure(error)
        })
        
        
    }
    

    
}
