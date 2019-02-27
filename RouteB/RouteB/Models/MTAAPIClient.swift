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
    static func searchAllBusRoutes(completionHandler: @escaping (AppError?, [List]?) -> Void) {
        let endpointURLString = "http://bustime.mta.info/api/where/routes-for-agency/MTA%20NYCT.json?key=\(SecretKeys.MTABusKey)"
        //        print(endpointURLString)
        NetworkHelper.shared.performDataTask(endpointURLString: endpointURLString) { (appError, data) in
            if let appError = appError {
                completionHandler(appError, nil)
            } else if let data = data {
                do {
                    let mtaInfo = try JSONDecoder().decode(MTABus.self, from: data)
                    completionHandler(nil, mtaInfo.data.list)
//                    let mtaInfo = try JSONDecoder().decode(MTAInfo.self, from: data)
//                    completionHandler(nil, mtaInfo.data.list)
                } catch {
                    completionHandler(AppError.jsonDecodingError(error), nil)
                    //                    print("1")
                }
            }
        }
    }
    
    static func searchLiveBusRoute(busLine: String, completionHandler: @escaping (AppError?, ServiceDelivery?) -> Void) {
        let endpointURLString = "http://bustime.mta.info/api/siri/vehicle-monitoring.json?key=\(SecretKeys.MTABusKey)&version=2&LineRef=\(busLine)"
                print(endpointURLString)
        NetworkHelper.shared.performDataTask(endpointURLString: endpointURLString) { (appError, data) in
            if let appError = appError {
                completionHandler(appError, nil)
            } else if let data = data {
                do {
                    let mtaInfo = try JSONDecoder().decode(BusLiveRoute.self, from: data)
                    completionHandler(nil, mtaInfo.Siri.ServiceDelivery)
                } catch {
                    completionHandler(AppError.jsonDecodingError(error), nil)
                    //                    print("1")
                }
            }
        }
    }
    
    static func getBusStops(busLine: String, completionHandler: @escaping (AppError?, [Stops]?) -> Void) {
        let endpointURLString = "http://bustime.mta.info/api/where/stops-for-route/\(busLine).json?key=\(SecretKeys.MTABusKey)&includePolylines=false&version=2"
        print(endpointURLString)
        NetworkHelper.shared.performDataTask(endpointURLString: endpointURLString) { (appError, data) in
            if let appError = appError {
                completionHandler(appError, nil)
            } else if let data = data {
                do {
                    let busStopInfo = try JSONDecoder().decode(BusStops.self, from: data)
                    completionHandler(nil, busStopInfo.data.references.stops)
                } catch {
                    completionHandler(AppError.jsonDecodingError(error), nil)
                    //                    print("1")
                }
            }
        }
    }
}
