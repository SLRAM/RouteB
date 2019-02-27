//
//  BusStops.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/26/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import Foundation

struct BusStops: Codable {
    let code: Int
    let currentTime: Int
    let data: BusStopData
}

struct BusStopData: Codable {
    let references: References
}

struct References: Codable {
    let stops: [Stops]
}
struct Stops: Codable {
    let code: String
    let direction: String
    let id: String
    let lat: Double
    let locationType: Int
    let lon: Double
    let name: String
    let routeIds: [String]
    let wheelchairBoarding: String
}
//struct <#name#>: Codable {
//    <#fields#>
//}
//struct <#name#>: Codable {
//    <#fields#>
//}
