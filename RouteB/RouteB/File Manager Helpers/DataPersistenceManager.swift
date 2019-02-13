//
//  DataPersistenceManager.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/12/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import Foundation

final class DataPersistenceManager {
    private init() {}
    
    static func documentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    static func filepathToDocumentsDirectory(filename: String) -> URL {
        return documentsDirectory().appendingPathComponent(filename)
    }
}
