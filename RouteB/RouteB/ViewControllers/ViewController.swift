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
        if !myRoutes.isEmpty {
            noRoutesView.alpha = 0
        }
    }
    
    func designSetup() {
        //        tableView.backgroundColor = .blue
        tableView.tableFooterView = UIView()
        let backgroundImage = UIImage(named: "blueGreen")
        let imageView = UIImageView(image: backgroundImage)
        tableView.backgroundView = imageView

//        self.navigationController!.navigationBar.barTintColor = UIColor.black

    }
    func characterFromInt(index : Int) -> String {
        let startingValue = Int(("A" as UnicodeScalar).value)
        var characterString = ""
        characterString.append(Character(Unicode.Scalar(startingValue + index)!))
        return characterString
    }
}
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return myRoutes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell", for: indexPath) as? MyTableViewCell else {return UITableViewCell()}

        let cellNumber = indexPath.section
        
        
        
        if cellNumber > 25 {
            let number = cellNumber - 25
            cell.tableLabel.text = "Route \(number)"
        } else {
            let letter = characterFromInt(index: cellNumber)
            cell.tableLabel.text = "Route \(letter)"
        }
        let route = myRoutes[cellNumber]
        let buses = route.transportation
        cell.backgroundColor = .green
        
        //pull this code out and create a helper method/func and add in activity indicator?
        var statusArray = [[String]]()
        var conditionArray = [[String]]()


        MTAAPIClient.getBusInfo(advisoryMessage: true, buses: buses) { (advisoryMessage, activeBuses) in
            DispatchQueue.main.async {

                if let advisoryMessage = advisoryMessage {
                    for message in advisoryMessage {
                        guard let conditions = message.Consequences.Consequence.first?.Condition else {return}
//                        print(conditions)
                        conditionArray.append(conditions)
                        //store conditions in an array and check if array contains delayed or noservice if yes then red else yellow. one run
                        
                        
                        if !conditions.isEmpty {
                            cell.backgroundColor = .yellow
//                            if conditionArray.contains(["delayed"]) {
//                                print("contained")
//                                cell.backgroundColor = .red
//                            }
                            
                            
                            for condition in conditions {
                                if condition.contains("delayed") || condition.contains("noService") {
                                    cell.backgroundColor = .red
                                }
                            }
                        }
                        statusArray.append(message.Description)
                        cell.warning = statusArray
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
            myRoutes.remove(at: indexPath.section)
            tableView.deleteSections([indexPath.section], with: .automatic)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
            RouteModel.deleteRoute(index: indexPath.section)
            if !myRoutes.isEmpty {
                noRoutesView.alpha = 0
            } else {
                noRoutesView.alpha = 1
            }
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
