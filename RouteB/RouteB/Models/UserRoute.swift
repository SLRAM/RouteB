//
//  Route.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/12/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import Foundation
//import CoreLocation

struct UserRoute: Codable {
    let startingAddressLat: Double
    let startingAddressLong: Double

    let endingAddressLat: Double
    let endingAddressLong: Double

    let transportation: [String]

//    public var coordinate: CLLocationCoordinate2D {
//        return CLLocationCoordinate2DMake(lat, lon)
//    }
}
