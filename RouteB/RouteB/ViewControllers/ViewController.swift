//
//  ViewController.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/7/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import UIKit

//additions: add train info

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noRoutesView: UIView!
    
    var myRoutes = [UserRoute]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designSetup()
        myRoutes = RouteModel.getRoutes()
        if !myRoutes.isEmpty {
            noRoutesView.alpha = 0
        }
        tableView.dataSource = self
        tableView.delegate = self
        
        print(DataPersistenceManager.documentsDirectory())
//        MTAAPIClient.searchNYCTBusRoutes { (appError, routes) in
//            if let routes = routes {
//                for route in routes {
////                    print("(\"\(route.id)\", \"\(route.shortName)\"),")
//                    print("\"\(route.id)\",")
//                }
//            }
//        }
//        MTAAPIClient.searchMTABCBusRoutes { (appError, routes) in
//            if let routes = routes {
//                for route in routes {
////                    print("(\"\(route.id)\", \"\(route.shortName)\"),")
//                    print("\"\(route.id)\",")
//
//                }
//            }
//        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myRoutes = RouteModel.getRoutes()
        tableView.reloadData()
    }
    
    func designSetup() {
        //        tableView.backgroundColor = .blue
        tableView.tableFooterView = UIView()
        let backgroundImage = UIImage(named: "blueGreen")
        let imageView = UIImageView(image: backgroundImage)
        tableView.backgroundView = imageView

//        self.navigationController!.navigationBar.barTintColor = UIColor.black

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
                        print(conditions)
                        //store conditions in an array and check if array contains delayed or noservice if yes then red else yellow. one run
                        if !conditions.isEmpty {
                            cell.backgroundColor = .yellow
                            for condition in conditions {
                                if condition.contains("delayed") || condition.contains("noService") {
                                    cell.backgroundColor = .red
                                }
                            }
                        }
                        let conditionDescription = message.Description
                        cell.warning = conditionDescription
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
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? MyTableViewCell else {return}
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "GoogleMapsViewController") as! GoogleMapsViewController
        let route = myRoutes[indexPath.row]
        viewController.myRoute = route
        viewController.advisoryMessages = selectedCell.warning
        viewController.statusColor = selectedCell.backgroundColor
        navigationController?.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let maskPathAll = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: 5.0, height: 5.0))
        let shapeLayerAll = CAShapeLayer()
        shapeLayerAll.frame = cell.bounds
        shapeLayerAll.path = maskPathAll.cgPath
        cell.layer.mask = shapeLayerAll
    }
}
