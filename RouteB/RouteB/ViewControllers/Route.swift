//
//  Route.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/12/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import Foundation

struct Route: Codable {
    let startingAddress: String
    let endingAddress: String
    let transportation: [String]
}
