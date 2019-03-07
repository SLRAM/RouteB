//
//  SearchViewController.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/13/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var busTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var savedBuses = [(String, String)]()
    
    var buses = BusIDs.BusIDs
    override func viewDidLoad() {
        super.viewDidLoad()
        print(buses)
        searchBar.delegate = self
        busTableView.delegate = self
        busTableView.dataSource = self
        addButton()

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
            let alertController = UIAlertController(title: "These buses has been added to your route.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if + add -SBS
//        let searchResult = searchResults[indexPath.row]
//        let busName = buses[indexPath.row].1
        let bus = buses[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
//        let busShortName = bus
        
        if let range = bus.range(of: "_") {
            let busShortName = bus[range.upperBound...]
            print(busShortName)
            let newBusFormat = busShortName.replacingOccurrences(of: "+", with: "-SBS")
            cell.textLabel?.text = newBusFormat
        }
        
        
        
        
        
//        cell.textLabel?.text = bus
        
//        cell.textLabel?.text = busName
////        cell.textLabel?.text = searchResult.title
////        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

