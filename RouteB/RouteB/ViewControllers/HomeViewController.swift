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

class HomeViewController: UIViewController {
    
    
    private let homeView = HomeView()
    public let identifer = "marker"
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    var locationCoordinate: CLLocationCoordinate2D!
    
    
    var mapView: GMSMapView?
    
//    private let homeListView = HomeListView()
//
//
//    private let searchbarView = SearchBarView()
//    private var venues = [Venues]()
    //    let testingCoordinate = CLLocationCoordinate2D.init(latitude: 40.7484, longitude: -73.9857)
    var query : String?
    var near = String()
    var locationString = String()
    var statusRawValue = Int32()
    var userLocation : CLLocationCoordinate2D?
    var updatedUserLocation = CLLocationCoordinate2D()
    class MyAnnotation: MKPointAnnotation {
        var tag: Int!
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        GMSServices.provideAPIKey(SecretKeys.googleKey)

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
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "List", style: .plain, target: self, action: #selector(toggle))
    }
    
    @objc func toggle() {
        print("pressed toggle")

            if navigationItem.rightBarButtonItem?.title == "List" {
                navigationItem.rightBarButtonItem?.title = "Map"
            } else {
                navigationItem.rightBarButtonItem?.title = "List"
            }
            homeViewSetup()
        
    }
    func homeViewSetup() {
        view.addSubview(homeView)
        homeView.myTableView.delegate = self
        homeView.myTableView.dataSource = self
        
        if navigationItem.rightBarButtonItem?.title == "Map" {
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
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        homeView.locationSearch.text = "\(completion.title) \(completion.subtitle)"
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            self.locationCoordinate = response?.mapItems[0].placemark.coordinate
            print("Ending coordinate: \(String(describing: self.locationCoordinate))")
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            self.homeView.myMapView.alpha = 1.0
        })
        self.view.addSubview(homeView)
        homeView.reloadInputViews()
        
            
            
//        guard let selectedCell = homeView.myTableView.cellForRow(at: indexPath) as? HomeListTableViewCell else {return}
//        let venue = venues[indexPath.row]
//        let detailVC = HomeDetailViewController()
//        detailVC.venue = venue
//        detailVC.homeDetailView.detailImageView.image = selectedCell.cellImage.image
//        //        detailVC
//        //        UIView.animate(withDuration: 5.5, delay: 0.0, options: [], animations: {
//        //        })
//        navigationController?.pushViewController(detailVC, animated: true)
    }
}
//extension HomeViewController: MKMapViewDelegate{
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard annotation is MKPointAnnotation else { return nil }
//
//        let identifier = "Annotation"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//
//        if annotationView == nil {
//            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            annotationView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
//            annotationView!.canShowCallout = true
//        } else {
//            annotationView!.annotation = annotation
//        }
//        return annotationView
//    }
//
//}

extension HomeViewController: GMSMapViewDelegate {
    
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
//extension HomeViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        print("user changed the authorization")
//        statusRawValue = status.rawValue
//        let currentLocation = homeView.mapView.userLocation
//        let myCurrentRegion = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 9000, longitudinalMeters: 9000)
//        homeView.mapView.setRegion(myCurrentRegion, animated: true)
//        print(status.rawValue)
//    }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("user has changed locations")
//        guard let currentLocation = locations.last else {return}
//        updatedUserLocation = currentLocation.coordinate
//        print("The user is in lat: \(currentLocation.coordinate.latitude) and long:\(currentLocation.coordinate.longitude)")
//        //        let myCurrentRegion = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 9000, longitudinalMeters: 9000)
//        //        homeView.mapView.setRegion(myCurrentRegion, animated: true)
//        //        getVenues(userLocation: updatedUserLocation, near: "", query: "Taco")
//    }
//}
