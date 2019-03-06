//
//  HomeViewController.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 3/4/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps

protocol HomeViewControllerDelegate: AnyObject {
//    func getLocation(location: Dictionary<String,CLLocationCoordinate2D>)
    func getLocation(buttonTag: Int, locationTuple: (String, CLLocationCoordinate2D))

}
class HomeViewController: UIViewController {
    
    weak var delegate: HomeViewControllerDelegate?
    private let homeView = HomeView()
    public let identifer = "marker"
    var allMarkers = [GMSMarker]()
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var locationCoordinate: CLLocationCoordinate2D?
    var tag: Int?

    var query : String?
    var near = String()
    var locationString = String()
    var locationTuple = (str:"", location:CLLocationCoordinate2D.init())
    var statusRawValue = Int32()
    var userLocation : CLLocationCoordinate2D?
    var updatedUserLocation = CLLocationCoordinate2D()
    class MyAnnotation: MKPointAnnotation {
        var tag: Int!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapListButton()
        homeView.delegate = self
        homeViewSetup()
        searchCompleter.delegate = self
        //        centerOnMap(location: initialLocation)
//        homeView.mapView.delegate = self
//        homeView.locationTextField.delegate = self
        homeView.locationSearch.delegate = self
        // setupAnnotations()
        
    

    }
    
    func mapListButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Add", style: .plain, target: self, action: #selector(addButton))
    }
    
    @objc func addButton() {
        guard let noLocation = homeView.locationSearch.text?.isEmpty else {return}
        if noLocation {
            let alertController = UIAlertController(title: "Please provide a location to add to your route.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        } else {
            guard let buttonTag = tag else {return}
            delegate?.getLocation(buttonTag: buttonTag, locationTuple: locationTuple)
            let alertController = UIAlertController(title: "This location has been added to your route.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    }
    func homeViewSetup() {
        view.addSubview(homeView)
        homeView.myTableView.delegate = self
        homeView.myTableView.dataSource = self
    }
}
extension HomeViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = homeView.myTableView.dequeueReusableCell(withIdentifier: "HomeListTableViewCell", for: indexPath) as? HomeListTableViewCell else {return UITableViewCell()}
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //do code here to make sure coordinates are obtained from location. possible alert saying sorry the location you entered could not be found try again.
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        let completionFull = "\(completion.title) \(completion.subtitle)"
        homeView.locationSearch.text = completionFull
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            self.locationCoordinate = response?.mapItems[0].placemark.coordinate
            print("Ending coordinate: \(String(describing: self.locationCoordinate))")
            DispatchQueue.main.async {
                guard let inputLocation = self.locationCoordinate else {return}
                self.locationTuple = (completionFull, inputLocation)

                self.homeView.myMapView.animate(toLocation: CLLocationCoordinate2D(latitude: inputLocation.latitude, longitude: inputLocation.longitude))
                let locate = GMSCameraPosition.camera(withLatitude: inputLocation.latitude,
                                                      longitude: inputLocation.longitude,
                                                      zoom: 17)
                for marker in self.allMarkers {
                    marker.map = nil
                }
                self.allMarkers.removeAll()
                let locationMarker = GMSMarker.init()
                locationMarker.position = inputLocation
                locationMarker.title = "Starting"
                locationMarker.map = self.homeView.myMapView
                self.allMarkers.append(locationMarker)
            }
            
            
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            self.homeView.myMapView.alpha = 1.0
            
            
        })
        
        //add map code here
        self.view.addSubview(homeView)
        homeView.reloadInputViews()
    }
}

extension HomeViewController: GMSMapViewDelegate {
//    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        print("camera changed")
//    }
//    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        print("updating")
//    }
    
    
}
extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("typing")
        
        if searchText.count > 0 {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.homeView.myMapView.alpha = 0.0
            })
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.homeView.myMapView.alpha = 1.0
            })
            self.view.addSubview(homeView)
            homeView.reloadInputViews()
        }
        searchCompleter.queryFragment = searchText
        
    }
}
extension HomeViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        homeView.myTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension HomeViewController: HomeViewDelegate {
    func userLocationButton() {
        print("pushed")
    }
}
