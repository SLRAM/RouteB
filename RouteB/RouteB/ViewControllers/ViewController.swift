//
//  ViewController.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/7/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var myRoutes = [Route]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        myRoutes = RouteModel.getRoutes()
        print(DataPersistenceManager.documentsDirectory())
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myRoutes = RouteModel.getRoutes()
        tableView.reloadData()
    }


}
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myRoutes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell", for: indexPath) as? MyTableViewCell else {return UITableViewCell()}
        cell.tableLabel.text = "Route \(indexPath.row + 1)"
        return cell
    }
    
    
}
