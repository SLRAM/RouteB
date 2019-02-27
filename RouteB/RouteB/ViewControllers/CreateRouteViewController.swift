//
//  CreateRouteViewController.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/11/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import UIKit
import MapKit

class CreateRouteViewController: UIViewController {
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var createButton: UIBarButtonItem!
//    @IBOutlet weak var startingAddressField: UITextField!
    @IBOutlet weak var startingAddressSearchBar: UISearchBar!
//    @IBOutlet weak var startingAddressTableView: UITableView!
//    @IBOutlet weak var endingAddressField: UITextField!
    @IBOutlet weak var endingAddressSearchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var busSearchBar: UISearchBar!
//    @IBOutlet weak var transportationField: UITextField!
    @IBOutlet weak var createTableView: UITableView!
    @IBOutlet weak var addTransportButton: UIButton!
    
    var transportationArray = [String]()
    var startingAddressLat = Double()
    var startingAddressLong = Double()
    var endingAddressLat = Double()
    var endingAddressLong = Double()
    var allBusesArray = [String]()
    var currentSearchBar = Int()
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    private var MTABusesList = [List]() {
        didSet {
            DispatchQueue.main.async {
                //reload a table view here
            }
        }
    }
    
    
    var startingCoordinate: CLLocationCoordinate2D!
    var endingCoordinate: CLLocationCoordinate2D!
    
    let address = "89 Metropolitan Oval Bronx NY"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBusList()

        startingAddressSearchBar.delegate = self
//        startingAddressTableView.delegate = self
//        startingAddressTableView.dataSource = self
        
        endingAddressSearchBar.delegate = self
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        busSearchBar.delegate = self
        
        searchCompleter.delegate = self
        createTableView.dataSource = self
        createTableView.delegate = self
        
//        startingAddressTableView.isHidden = true
        searchTableView.isHidden = true
        
        

        
//        getCoordinate(addressString: address) { (foundAddress, error) in
//            if let _ = error {
//                return
//            }
//            let foundAddressLat = foundAddress.latitude,
//            foundAddressLong = foundAddress.longitude
//            print("lat: \(foundAddressLat) long: \(foundAddressLong)")
//        }
    }
    func searchBusList() {
        
        MTAAPIClient.searchAllBusRoutes { (error, list) in
            if let error = error {
                print("Error getting bus list: \(error)")
            } else if let list = list {
                self.MTABusesList = list
//                print(list.count)
                for bus in 0...self.MTABusesList.count-1 {
                    print(bus)
//                    self.allBusesArray.append(self.MTABusesList[bus].shortName)
                    self.allBusesArray.append(self.MTABusesList[bus].id)
                }
            }
        }
    }
    
    private func saveRoute()-> UserRoute? {
        //add found address lat long here
        let startingAddressLat = startingCoordinate.latitude
        let startingAddressLong = startingCoordinate.longitude

        let endingAddressLat = endingCoordinate.latitude
        let endingAddressLong = endingCoordinate.longitude
        
//        getCoordinate(addressString: startingAddress) { (foundAddress, error) in
//            if let _ = error {
//                return
//            } else if let foundAddress = foundAddress {
//            print(foundAddress.latitude)
//
//            self.startingAddressLat = foundAddress.latitude
//            self.startingAddressLong = foundAddress.longitude
////            print("lat: \(foundAddressLat) long: \(foundAddressLong)")
//            }
//        }
//        getCoordinate(addressString: endingAddress) { (foundAddress, error) in
//            if let _ = error {
//                return
//            }
//            self.endingAddressLat = foundAddress.latitude
//            self.endingAddressLong = foundAddress.longitude
////            print("lat: \(foundAddressLat) long: \(foundAddressLong)")
//        }
        
        
        let savedRoute = transportationArray
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.dateStyle = DateFormatter.Style.long
//        formatter.timeStyle = .medium
//        let timestamp = formatter.string(from: date)
        let route = UserRoute.init(startingAddressLat: startingAddressLat, startingAddressLong: startingAddressLong, endingAddressLat: endingAddressLat, endingAddressLong: endingAddressLong, transportation: savedRoute)
        return route
    }

    
    func getCoordinate( addressString : String,
                        completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createPressed(_ sender: UIBarButtonItem) {
        guard let route = saveRoute() else {return}
        RouteModel.appendRoute(route: route)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addTransportButtonPressed(_ sender: UIButton) {
        print("added")
        if let transportation = busSearchBar.text {
            searchTableView.reloadData()
            //create anothert model of the bus itself and save that to the plist instead
            transportationArray.append(transportation)
            busSearchBar.text = ""
            createTableView.reloadData()
            print(transportationArray.count)
            print(transportationArray[transportationArray.count-1].description)
        }
    }
}
extension CreateRouteViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
}

extension CreateRouteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == searchTableView){
            return searchResults.count
        } else {
            return transportationArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == searchTableView){
            //if textfield
            if currentSearchBar == 0 || currentSearchBar == 1 {
                let searchResult = searchResults[indexPath.row]
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
                cell.textLabel?.text = searchResult.title
                cell.detailTextLabel?.text = searchResult.subtitle
                return cell
            } else {
                let searchResult = allBusesArray[indexPath.row]
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
                cell.textLabel?.text = searchResult.description
//                cell.detailTextLabel?.text = //this will hide id but textlabel will show short name
                return cell
            }
            
        } else {
            guard let cell = createTableView.dequeueReusableCell(withIdentifier: "MyCreateTableViewCell", for: indexPath) as? MyCreateTableViewCell else {return UITableViewCell()}
            print(transportationArray[indexPath.row].description)
            let route = transportationArray[indexPath.row]
            cell.createdLabel.text = route
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == searchTableView) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let completion = searchResults[indexPath.row]
            let busSelected = allBusesArray[indexPath.row]
            print(allBusesArray.count)
            print(searchResults[indexPath.row])
            
            if currentSearchBar == 0 {
                startingAddressSearchBar.text = "\(completion.title) \(completion.subtitle)"
                let searchRequest = MKLocalSearch.Request(completion: completion)
                let search = MKLocalSearch(request: searchRequest)
                search.start { (response, error) in
                    self.startingCoordinate = response?.mapItems[0].placemark.coordinate
                    print("Ending coordinate: \(String(describing: self.startingCoordinate))")
                    self.searchTableView.isHidden = true
                }
            } else if currentSearchBar == 1 {
                endingAddressSearchBar.text = "\(completion.title) \(completion.subtitle)"
                
                let searchRequest = MKLocalSearch.Request(completion: completion)
                let search = MKLocalSearch(request: searchRequest)
                search.start { (response, error) in
                    self.endingCoordinate = response?.mapItems[0].placemark.coordinate
                    print("Ending coordinate: \(String(describing: self.endingCoordinate))")
                    self.searchTableView.isHidden = true
                }
            } else {
                busSearchBar.text = "\(busSelected.description)"
                //use for bus tableview
            }
            
        } else {
            
        }
    }
}
extension CreateRouteViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar == startingAddressSearchBar {
            print("First clicked")
            currentSearchBar = 0
            searchCompleter.queryFragment = searchText
//            startingAddressTableView.isHidden = false
            searchTableView.isHidden = false
        }
        if searchBar == endingAddressSearchBar {
            print("Second clicked")
            currentSearchBar = 1
            searchCompleter.queryFragment = searchText
            searchTableView.isHidden = false
        }
        if searchBar == busSearchBar {
            print("Third clicked")
            currentSearchBar = 2
            searchTableView.isHidden = false
            searchTableView.reloadData()

        }

    }
}

extension CreateRouteViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
//        startingAddressTableView.reloadData()
        searchTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

