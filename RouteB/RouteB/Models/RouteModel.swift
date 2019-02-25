//
//  RouteModel.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/12/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import Foundation

final class RouteModel {
    private static let filename = "SavedRouteList.plist"
    private static var routes = [Route]()
    private init() {}
    static func appendRoute(route: Route) {
        routes.append(route)
        saveRoute()
    }
//    static func bookAlreadyFavorited(newTitle: String)-> Bool {
//        var title = false
//        if favorites.isEmpty {
//            return title
//        } else {
//            for num in 0...favorites.count - 1 {
//                if favorites[num].title == newTitle {
//                    title = true
//                }
//            }
//        }
//        return title
//    }
    
    static func saveRoute() {
        let path = DataPersistenceManager.filepathToDocumentsDirectory(filename: filename)
        
        do {
            let data = try PropertyListEncoder().encode(routes)
            try data.write(to: path, options: .atomic)
        } catch {
            print("property list encoder: \(error)")
        }
    }
    static func deleteRoute(index: Int) {
        routes.remove(at: index)
        saveRoute()
    }
    static func getRoutes() -> [Route] {
        let path = DataPersistenceManager.filepathToDocumentsDirectory(filename: filename).path
        
        if FileManager.default.fileExists(atPath: path) {
            if let data = FileManager.default.contents(atPath: path) {
                do {
                    routes = try PropertyListDecoder().decode([Route].self, from: data)
                } catch {
                    print("Property list decoding error: \(error)")
                }
            } else {
                print("getPhotoJournal - data is nil")
            }
        } else {
            print("\(filename) does not exist")
        }
//        favorites = favorites.sorted {$0.createdAt > $1.createdAt}
        return routes
    }
}
