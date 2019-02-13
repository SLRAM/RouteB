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
    @IBOutlet weak var startingAddressField: UITextField!
    @IBOutlet weak var startingAddressSearchBar: UISearchBar!
    @IBOutlet weak var startingAddressTableView: UITableView!
    @IBOutlet weak var endingAddressField: UITextField!
    @IBOutlet weak var endingAddressSearchBar: UISearchBar!
    @IBOutlet weak var endingAddressTableView: UITableView!
    @IBOutlet weak var transportationField: UITextField!
    @IBOutlet weak var createTableView: UITableView!
    @IBOutlet weak var addTransportButton: UIButton!
    
    var transportationArray = [String]()
    var startingAddressLat = Double()
    var startingAddressLong = Double()
    var endingAddressLat = Double()
    var endingAddressLong = Double()
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    
    var startingCoordinate: CLLocationCoordinate2D!
    var endingCoordinate: CLLocationCoordinate2D!
    
    let address = "89 Metropolitan Oval Bronx NY"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        startingAddressSearchBar.delegate = self
        startingAddressTableView.delegate = self
        startingAddressTableView.dataSource = self
        
        endingAddressSearchBar.delegate = self
        endingAddressTableView.delegate = self
        endingAddressTableView.dataSource = self
        
        searchCompleter.delegate = self
        createTableView.dataSource = self
        createTableView.delegate = self
        
        startingAddressTableView.isHidden = true
        endingAddressTableView.isHidden = true
        

        
//        getCoordinate(addressString: address) { (foundAddress, error) in
//            if let _ = error {
//                return
//            }
//            let foundAddressLat = foundAddress.latitude,
//            foundAddressLong = foundAddress.longitude
//            print("lat: \(foundAddressLat) long: \(foundAddressLong)")
//        }
    }
    
    private func saveRoute()-> Route? {
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
        let route = Route.init(startingAddressLat: startingAddressLat, startingAddressLong: startingAddressLong, endingAddressLat: endingAddressLat, endingAddressLong: endingAddressLong, transportation: savedRoute)
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
        if let transportation = transportationField.text {
            transportationArray.append(transportation)
            transportationField.text = ""
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
        if (tableView == startingAddressTableView) || (tableView == endingAddressTableView){
            return searchResults.count
        } else {
            return transportationArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == startingAddressTableView) || (tableView == endingAddressTableView){
            let searchResult = searchResults[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = searchResult.title
            cell.detailTextLabel?.text = searchResult.subtitle
            return cell
        } else {
            guard let cell = createTableView.dequeueReusableCell(withIdentifier: "MyCreateTableViewCell", for: indexPath) as? MyCreateTableViewCell else {return UITableViewCell()}
            print(transportationArray[indexPath.row].description)
            let route = transportationArray[indexPath.row]
            cell.createdLabel.text = route
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == startingAddressTableView){
            tableView.deselectRow(at: indexPath, animated: true)
            
            let completion = searchResults[indexPath.row]
            print(searchResults[indexPath.row])
            startingAddressSearchBar.text = "\(completion.title) \(completion.subtitle)"
            
            let searchRequest = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                self.startingCoordinate = response?.mapItems[0].placemark.coordinate
                print("Starting coordinate: \(String(describing: self.startingCoordinate))")
                self.startingAddressTableView.isHidden = true
            }
        } else if (tableView == endingAddressTableView) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let completion = searchResults[indexPath.row]
            print(searchResults[indexPath.row])
            endingAddressSearchBar.text = "\(completion.title) \(completion.subtitle)"
            
            let searchRequest = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                self.endingCoordinate = response?.mapItems[0].placemark.coordinate
                print("Ending coordinate: \(String(describing: self.endingCoordinate))")
                self.endingAddressTableView.isHidden = true
            }
        } else {
            
        }
    }
}
extension CreateRouteViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar == startingAddressSearchBar {
            searchCompleter.queryFragment = searchText
            startingAddressTableView.isHidden = false
        }
        if searchBar == endingAddressSearchBar {
            searchCompleter.queryFragment = searchText
            endingAddressTableView.isHidden = false
        }

    }
}

extension CreateRouteViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        startingAddressTableView.reloadData()
        endingAddressTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

