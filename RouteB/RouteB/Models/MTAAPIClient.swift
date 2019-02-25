//
//  MTAAPIClient.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/25/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import Foundation
import MapKit

//http://bustime.mta.info/api/where/routes-for-agency/MTA%20NYCT.json?key=76019626-1461-46da-988a-2a0fb97892e6

final class MTAAPIClient {
    
    private init() {}
    static func searchMTA(completionHandler: @escaping (AppError?, [MTABus]?) -> Void) {
        let endpointURLString = "http://bustime.mta.info/api/where/routes-for-agency/MTA%20NYCT.json?key=\(SecretKeys.MTABusKey)"
        //        print(endpointURLString)
        NetworkHelper.shared.performDataTask(endpointURLString: endpointURLString) { (appError, data) in
            if let appError = appError {
                completionHandler(appError, nil)
            }
            if let data = data {
                print(data)
            }
//            else if let data = data {
//                do {
//                    let busInfo = try JSONDecoder().decode(MTABus.self, from: data)
//                    completionHandler(nil, busInfo.data)
//                } catch {
//                    completionHandler(AppError.jsonDecodingError(error), nil)
//                    //                    print("1")
//                }
//            }
        }
    }
}
