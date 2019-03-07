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
    @IBOutlet var mapView: GMSMapView! //reacts diff if left as UIView
    
    var myMapView: GMSMapView?

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
        let camera = GMSCameraPosition.camera(withLatitude: 40.793840, longitude: 73.886012, zoom: 11)
        myMapView = GMSMapView.init(frame: CGRect.zero, camera: camera)
        //        mapView = GMSMapView.init(frame: CGRect.zero, camera: camera)
        //mapView = myMapView
        mapView.addSubview(myMapView!)
        searchCompleter.delegate = self
        createTableView.dataSource = self
        createTableView.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        let camera = GMSCameraPosition.camera(withLatitude: 40.793840, longitude: -73.886012, zoom: 11)
//        myMapView = GMSMapView.init(frame: CGRect.zero, camera: camera)
////        mapView = GMSMapView.init(frame: CGRect.zero, camera: camera)
//        mapView = myMapView
//        view.addSubview(mapView)
    }
    
    @IBAction func startingAddressClicked(_ sender: UIButton) {
        let detailVC = HomeViewController()
        detailVC.delegate = self
        detailVC.tag = 0
        navigationController?.pushViewController(detailVC, animated: true)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
//        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @IBAction func transportationButtonClicked(_ sender: UIButton) {
        
        //    old code
        //    @IBAction func addTransportButtonPressed(_ sender: UIButton) {
        //        print("added")
        //        if let transportation = busSearchBar.text {
        //            transportationArray.append(transportation)
        //            createTableView.reloadData()
        //            print(transportationArray.count)
        //            print(transportationArray[transportationArray.count-1].description)
        //        }
        //    }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        searchVC.delegate = self
        navigationController?.pushViewController(searchVC, animated: true)
    }
    @IBAction func endingAddressClicked(_ sender: UIButton) {
        let detailVC = HomeViewController()
        detailVC.delegate = self
        detailVC.tag = 1
        navigationController?.pushViewController(detailVC, animated: true)
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
        guard let route = saveRoute() else {return}
        RouteModel.appendRoute(route: route)
        dismiss(animated: true, completion: nil)
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
        print(transportationArray[indexPath.row].description)
        let route = transportationArray[indexPath.row]
        
        if let range = route.range(of: "_") {
            let busShortName = route[range.upperBound...]
            //            print(busShortName)
            let newBusFormat = busShortName.replacingOccurrences(of: "+", with: "-SBS")
            cell.createdLabel.text = newBusFormat
        }
        
        
//        cell.createdLabel.text = route
        
        
        
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
}

extension CreateRouteViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension CreateRouteViewController: HomeViewControllerDelegate {
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
        
        //if button text is changed then update map
    }

}
extension CreateRouteViewController: SearchViewControllerDelegate {
    func selectedBuses(buses: [String]) {
            transportationArray = buses
            createTableView.reloadData()
    }
    
    
}
