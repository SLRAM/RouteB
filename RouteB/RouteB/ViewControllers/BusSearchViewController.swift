//
//  SearchViewController.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/13/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import UIKit
import Foundation
protocol BusSearchViewControllerDelegate: AnyObject {
    func selectedBuses(buses: [String])
}
class BusSearchViewController: UIViewController {

    weak var delegate: BusSearchViewControllerDelegate?
    
    @IBOutlet weak var busTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var savedBuses = [String]()
    
    var buses = BusIDs.BusIDs
    var filteredBuses = [String]()
    
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buses.sort(by: {$0 < $1})
        filteredBuses = buses
        searchBar.delegate = self
//        searchBar.returnKeyType = UIReturnKeyType.done
        busTableView.delegate = self
        busTableView.dataSource = self
        addButton()

        designSetup()
    }
    
    func designSetup() {
        //        tableView.backgroundColor = .blue
        busTableView.tableFooterView = UIView()
        let backgroundImage = UIImage(named: "blueGreen")
        let imageView = UIImageView(image: backgroundImage)
        busTableView.backgroundView = imageView
        
        //        self.navigationController!.navigationBar.barTintColor = UIColor.black
        
    }
    
    
    func addButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Add", style: .plain, target: self, action: #selector(addButtonClicked))
    }
    
    @objc func addButtonClicked() {
        let noBuses = savedBuses.isEmpty
        if noBuses {
            let alertController = UIAlertController(title: "Please provide buses to add to your route.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
        
            present(alertController, animated: true)
        } else {
//            delegate?.getLocation(buttonTag: buttonTag, locationTuple: locationTuple)
            delegate?.selectedBuses(buses: savedBuses)
            let alertController = UIAlertController(title: "These buses have been added to your route.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                
//                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    }
}

extension BusSearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            isSearching = false
            view.endEditing(true)
        } else {
            isSearching = true
            filteredBuses = buses.filter({$0.lowercased().contains(searchText.lowercased())})
            
        }
        busTableView.reloadData()
    }
    
}

extension BusSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return filteredBuses.count
        } else {
            return buses.count
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if + add -SBS

        var bus = String()
        if isSearching {
            bus = filteredBuses[indexPath.row]
        } else {
            bus = buses[indexPath.row]
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.backgroundColor = .clear
        if let range = bus.range(of: "_") {
            let busShortName = bus[range.upperBound...]
//            print(busShortName)
            let newBusFormat = busShortName.replacingOccurrences(of: "+", with: "-SBS")
            cell.textLabel?.text = newBusFormat
        }
        if savedBuses.contains(bus) {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var bus = String()
        if isSearching {
            bus = filteredBuses[indexPath.row]

        } else {
            bus = buses[indexPath.row]
        }
        print(bus)
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            var counter = 0
            for savedBus in savedBuses {
                if savedBus != bus {
                    counter += 1
                }
            }
            savedBuses.remove(at: counter)
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            savedBuses.append(bus)
        }
        
    }
}

