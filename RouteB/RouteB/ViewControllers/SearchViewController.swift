//
//  SearchViewController.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/13/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var savedBuses = [(String, String)]()
    var buses = BusIDs.BusIDs
    override func viewDidLoad() {
        super.viewDidLoad()
        print(buses)
        searchBar.delegate = self
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
//        cell.textLabel?.text = searchResult.title
//        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

