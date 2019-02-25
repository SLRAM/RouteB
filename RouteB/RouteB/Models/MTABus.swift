//
//  MTABus.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/25/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import Foundation

struct MTABus: Codable {
    let data : [Data]
}
struct Data: Codable {
    let list : [List]
}
struct List: Codable {
    let agencyId: String
    let color: String
    let description: String
    let id: String
    let longName: String
    let shortName: String
    let textColor: String
    let type: Int
    let url: String
}

//use shortname for bus list, use url to open pdf, maybe use color for design
