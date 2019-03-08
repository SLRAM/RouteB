//
//  CreateRouteViewController.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/11/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

//change search function so that it segues to a mapview with a search bar ontop and the searchbar is it's own view same as foursquare. toggles out mapview for tableview when location is selected it shows on map then user can confirm location. potentially allow user to adjust location by dragging map around?

class CreateRouteViewController: UIViewController {
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var transportationButton: UIButton!
    @IBOutlet weak var createTableView: UITableView!
    @IBOutlet weak var startingAddressButton: UIButton!
    @IBOutlet weak var endingAddressButton: UIButton!

    var startingCoordinate: CLLocationCoordinate2D!
    var startingAddressLat = Double()
    var startingAddressLong = Double()
    
    var endingCoordinate: CLLocationCoordinate2D!
    var endingAddressLat = Double()
    var endingAddressLong = Double()
    
    var transportationArray = [String]()

    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    private var MTABusesList = [List]() {
        didSet {
            DispatchQueue.main.async {
                //reload a table view here
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
        createTableView.dataSource = self
        createTableView.delegate = self
        designSetup()
    }
    
    func designSetup() {
        //        tableView.backgroundColor = .blue
        createTableView.tableFooterView = UIView()
        let backgroundImage = UIImage(named: "blueGreen")
        let imageView = UIImageView(image: backgroundImage)
        createTableView.backgroundColor = .clear
        
        //        self.navigationController!.navigationBar.barTintColor = UIColor.black
        
    }
    
    

    
    @IBAction func startingAddressClicked(_ sender: UIButton) {
        let detailVC = LocationSearchViewController()
        detailVC.delegate = self
        detailVC.tag = 0
        navigationController?.pushViewController(detailVC, animated: true)
    }
    

    @IBAction func endingAddressClicked(_ sender: UIButton) {
        let detailVC = LocationSearchViewController()
        detailVC.delegate = self
        detailVC.tag = 1
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @IBAction func transportationButtonClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! BusSearchViewController
        searchVC.delegate = self
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    
    private func saveRoute()-> UserRoute? {
        let startingAddressLat = startingCoordinate.latitude
        let startingAddressLong = startingCoordinate.longitude

        let endingAddressLat = endingCoordinate.latitude
        let endingAddressLong = endingCoordinate.longitude

        let savedRoute = transportationArray
        
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
        if startingAddressButton.titleLabel?.text == "Add Starting Address" || endingAddressButton.titleLabel?.text == "Add Ending Address" || transportationArray.count == 0 {
            let alertController = UIAlertController(title: "Please fill in required areas to save route.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true)
            
            
        } else {
            
            let alertController = UIAlertController(title: "This route has been saved.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in

                guard let route = self.saveRoute() else {return}
                RouteModel.appendRoute(route: route)
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okAction)
            present(alertController, animated: true)
            
        }
    }

}

extension CreateRouteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transportationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = createTableView.dequeueReusableCell(withIdentifier: "MyCreateTableViewCell", for: indexPath) as? MyCreateTableViewCell else {return UITableViewCell()}
        cell.backgroundColor = .clear
        print(transportationArray[indexPath.row].description)
        let route = transportationArray[indexPath.row]
        
        if let range = route.range(of: "_") {
            let busShortName = route[range.upperBound...]
            let newBusFormat = busShortName.replacingOccurrences(of: "+", with: "-SBS")
            cell.createdLabel.text = newBusFormat
        }
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            transportationArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }
}

extension CreateRouteViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension CreateRouteViewController: LocationSearchViewControllerDelegate {
    func getLocation(buttonTag: Int, locationTuple: (String, CLLocationCoordinate2D)) {
        if buttonTag == 0 {
            print("tuple printout of string: \(locationTuple.0)")
            print("tuple printout of coordinates: \(locationTuple.1)")
            startingCoordinate = locationTuple.1
            startingAddressButton.setTitle(locationTuple.0, for: .normal)
            startingAddressButton.titleLabel?.text = locationTuple.0
        } else {
            print("tuple printout of string: \(locationTuple.0)")
            print("tuple printout of coordinates: \(locationTuple.1)")
            endingCoordinate = locationTuple.1
            endingAddressButton.setTitle(locationTuple.0, for: .normal)
            endingAddressButton.titleLabel?.text = locationTuple.0
        }
    }

}
extension CreateRouteViewController: BusSearchViewControllerDelegate {
    func selectedBuses(buses: [String]) {
            transportationArray = buses
            createTableView.reloadData()
    }
}
