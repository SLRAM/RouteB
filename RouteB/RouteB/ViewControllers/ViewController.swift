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
    var advisoryMessages = [String]()
    
    var myRoutes = [UserRoute]() {
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
//        MTAAPIClient.searchNYCTBusRoutes { (appError, routes) in
//            if let routes = routes {
//                for route in routes {
//                    print("\"\(route.id)\" : \"\(route.shortName)\",")
//                }
//            }
//        }
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
        let route = myRoutes[indexPath.row]
        let buses = route.transportation
        cell.tableLabel.text = "Route \(indexPath.row + 1)"
        cell.backgroundColor = .green
        //pull this code out and create a helper method/func and add in activity indicator?
        MTAAPIClient.getBusInfo(advisoryMessage: true, buses: buses) { (advisoryMessage, activeBuses) in
            if let advisoryMessage = advisoryMessage {
                for message in advisoryMessage {
                    DispatchQueue.main.async {
                        guard let conditions = message.Consequences.Consequence.first?.Condition else {return}
                        //fix so that if delayed comes up then it will always print out red maybe
                        var color = ""
                        for condition in conditions {
                            if color == "delayed" {
                                break
                            } else if color == "altered" {
                                switch condition {
                                case "altered":
                                    cell.backgroundColor = .yellow
                                case "delayed":
                                    cell.backgroundColor = .red
                                    color = "delayed"
                                default:
                                    print("unable to get background color")
                                }
                            } else {
                                switch condition {
                                case "altered":
                                    cell.backgroundColor = .yellow
                                    color = "altered"
                                case "delayed":
                                    cell.backgroundColor = .red
                                    color = "delayed"
                                default:
                                    print("unable to get background color")
                                }
                            }
                        }
                    }
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            myRoutes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            print(indexPath.row)
            RouteModel.deleteRoute(index: indexPath.row)
            //add code to plist to delete at
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let selectedCell = tableView.cellForRow(at: indexPath) as? MyTableViewCell else {return}
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        let viewController = storyboard.instantiateViewController(withIdentifier: "GoogleMapsViewController") as! GoogleMapsViewController
        let route = myRoutes[indexPath.row]
        let buses = route.transportation
        viewController.myRoute = route
        viewController.advisoryMessages = self.advisoryMessages
        navigationController?.pushViewController(viewController, animated: true)
    }
}
