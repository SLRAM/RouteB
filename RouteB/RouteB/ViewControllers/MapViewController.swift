//
//  MapViewController.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/11/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var routeStatus: UIBarButtonItem!
    @IBOutlet weak var editRoute: UIBarButtonItem!
    @IBOutlet weak var pinImage: UIImageView!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    
    
//    var startingAddressLat : Double?
//    var startingAddressLong : Double?
//    var endingAddressLat : Double?
//    var endingAddressLong : Double?
//    var transportationArray : [String]?
    var myRoute : UserRoute?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        pinImage.isHidden = true
        locationManager.delegate = self
        mapView.delegate = self
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            startTrackingUserLocation()
            getTransitDirections()

        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
        
        
        
        
    }
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {$0.cancel()}
//        directionsArray = []
    }
    func getRoute(lat: Double, long: Double)->CLLocationCoordinate2D {
        let coordinate = CLLocationCoordinate2D.init(latitude: lat, longitude: long)
        return coordinate
    }
//    func getDirections() {
//        guard let location = locationManager.location?.coordinate else {
//            print("error getting a location")
//            return
//        }
//        print("location: \(location)")
//        let request = createDirectionsRequest(from: location)
//        let directions = MKDirections(request: request)
//        resetMapView(withNew: directions)
//        directions.calculate { [unowned self](response, error) in
//            guard let response = response else {return}
//
//            for route in response.routes {
////                let steps = route.steps
//                self.mapView.addOverlay(route.polyline)
//                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
//                for steps in route.steps {
//                    print(steps.instructions)
//                }
//            }
//        }
//    }
    func getTransitDirections() {
        guard let startingLat = myRoute?.startingAddressLat,
            let startingLong = myRoute?.startingAddressLong else {
                print("unable to convert starting lat and long")
                return
        }
        guard let endingLat = myRoute?.endingAddressLat,
            let endingLong = myRoute?.endingAddressLong else {
                print("unable to convert starting lat and long")
                return
        }
        
        let startingCoordinate = getRoute(lat: startingLat, long: startingLong)
        let endingCoordinate = getRoute(lat: endingLat, long: endingLong)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startingCoordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endingCoordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .any
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 30.0, left: 30.0, bottom: 30.0, right: 30.0), animated: true)
                for steps in route.steps {
                    print(steps.instructions)
                }
            }
        }
    }
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate = getCenterLocation(for: mapView).coordinate
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        return request
    }
    @IBAction func goButtonTapped(_sender: UIButton) {
//        getDirections()
        //maybe live route directions could go here?
    }
    func startTrackingUserLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        previousLocation = getCenterLocation(for: mapView)
    }

    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    @IBAction func routeStatusPressed(_ sender: UIBarButtonItem) {
    }
    @IBAction func editRoutePressed(_ sender: UIBarButtonItem) {
    }
    
    
    
    
    
}
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("user changed the authorization")
        guard let startingLat = myRoute?.startingAddressLat,
            let startingLong = myRoute?.startingAddressLong else {
                print("unable to convert starting lat and long")
                return
        }
        guard let endingLat = myRoute?.endingAddressLat,
            let endingLong = myRoute?.endingAddressLong else {
                print("unable to convert starting lat and long")
                return
        }
        
        let startingCoordinate = getRoute(lat: startingLat, long: startingLong)
        let endingCoordinate = getRoute(lat: endingLat, long: endingLong)
        
//        let startingCoordinate = CLLocationCoordinate2D.init(latitude: startingLat, longitude: startingLong)
//
//        let endingCoordinate = CLLocationCoordinate2D.init(latitude: endingLat, longitude: endingLong)
        
        let myCurrentRegion = MKCoordinateRegion(center: startingCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(myCurrentRegion, animated: true)
        
        
        
//        let currentLocation = mapView.userLocation
//        let myCurrentRegion = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//        mapView.setRegion(myCurrentRegion, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("user has changed locations")
        guard let currentLocation = locations.last else {return}
        print("The user is in lat: \(currentLocation.coordinate.latitude) and long:\(currentLocation.coordinate.longitude)")
        let myCurrentRegion = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(myCurrentRegion, animated: true)
    }
}
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else {return}
        guard center.distance(from: previousLocation) > 50 else {return}
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self](placemarks, error) in
            guard let self = self else {return}
            
            if let _ = error {
                return
            }
            guard let placemark = placemarks?.first else {
                return
            }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .purple
        return renderer
    }
}
