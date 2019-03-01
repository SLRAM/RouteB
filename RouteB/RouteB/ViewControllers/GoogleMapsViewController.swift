//
//  GoogleMapsViewController.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/28/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import UIKit
import GoogleMaps
class GoogleMapsViewController: UIViewController {

    var myRoute : UserRoute?
    var mapView: GMSMapView?
    var buses = [String]()
//    var allAnnotations = [MKAnnotation]()
    var allMarkers = [GMSMarker]()

    var busStopPolylines = [GMSPolyline]() {
        didSet {
            DispatchQueue.main.async {
            }
        }
    }
    
//    var customIcon: GM = {
//        let icon = GMSMarker
//        icon.
//            path: google.maps.SymbolPath.CIRCLE,
//            fillColor: '#00F',
//            fillOpacity: 0.6,
//            strokeColor: '#00A',
//            strokeOpacity: 0.9,
//            strokeWeight: 1,
//            scale: 7
//        
//        
//        return icon
//    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let busesUnwrapped = myRoute?.transportation else {return}
        buses = busesUnwrapped
        GMSServices.provideAPIKey(SecretKeys.googleKey)
        setupView()
        loadBusRouteAndActiveOnRoute()
        timer()
    }
    
    func setupView() {
        let camera = GMSCameraPosition.camera(withLatitude: 40.838625, longitude: -73.861000, zoom: 15)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        let currentLocation = CLLocationCoordinate2D(latitude: 40.838625, longitude: -73.861000)
        let marker = GMSMarker(position: currentLocation)
        marker.title = "Home"
        marker.map = mapView
    }
    func timer() {
        let myTimer = Timer(timeInterval: 20.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        RunLoop.main.add(myTimer, forMode: RunLoop.Mode.default)
    }
    @objc func refresh() {
        // here is the label to refresh
        getActiveBusesOnRoute(buses: buses)
    }

    func loadBusRouteAndActiveOnRoute() {
        getBusStops(buses: buses)
        getActiveBusesOnRoute(buses: buses)
    }
    
    func getActiveBusesOnRoute(buses: [String]) {
        for marker in self.allMarkers {
            marker.map = nil
        }
        self.allMarkers.removeAll()
        
        for bus in buses {
            guard let search = bus.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {print("not a valid search")
                return
            }
            MTAAPIClient.searchLiveBusRoute(busLine: search) { (error, busInfo) in //weak self
                if let error = error {
                    print(error)
                }
                if let busInfo = busInfo {
                    guard let activeBuses = busInfo.VehicleMonitoringDelivery.first?.VehicleActivity else {return}
                    //get lat and long for bus
                    DispatchQueue.main.async {
                        self.setupMarkers(activeBuses: activeBuses)
                    }
                    
                }
            }
        }
        //
        
    }
    func setupMarkers(activeBuses: [VehicleActivity]){
        
        var count = 0
        
        for bus in activeBuses {
            
            print("bus number: \(count)")
            let busLat = bus.MonitoredVehicleJourney.VehicleLocation.Latitude
            let busLon = bus.MonitoredVehicleJourney.VehicleLocation.Longitude
            let coordinate = CLLocationCoordinate2D.init(latitude: busLat, longitude: busLon)
            
            let marker = GMSMarker(position: coordinate)
            marker.title = bus.MonitoredVehicleJourney.VehicleRef
            marker.snippet = "direction: \(bus.MonitoredVehicleJourney.DirectionRef)"
//            marker.icon = UIImage(named: "icons8-bus_stop")
            marker.icon = GMSMarker.markerImage(with: .purple)
            allMarkers.append(marker)
            DispatchQueue.main.async {
//                self.mapView.addAnnotations(self.allAnnotations)
                marker.map = self.mapView
            }
            
            count += 1
            
        }
    }
    
    func getBusStops(buses: [String]) {
        for bus in buses {
            guard let search = bus.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {print("not a valid search")
                return
            }
            MTAAPIClient.getBusStops(busLine: search) { (error, data) in //weak self
                if let error = error {
                    print("error getting bus stops: \(error)")
                }
                if let data = data {
                    let polylinesMTA = data.entry.polylines
                    for poly in polylinesMTA {
                        DispatchQueue.main.async {
                            let polyline = GMSPolyline(path: GMSPath.init(fromEncodedPath: poly.points))
                            self.busStopPolylines.append(polyline)
            
//                            guard let busStop = polyline.path?.coordinate(at: 0) else {return}
//                            let marker = GMSMarker(position: busStop)
//                            marker.map = self.mapView
                            polyline.map = self.mapView
                            
                        }
                    }
                    let stops = data.references.stops
                    for stop in stops {
                        print(stop.name)
                        DispatchQueue.main.async {
                            let busStop = CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.lon)
                            let marker = GMSMarker(position: busStop)
                            marker.icon = UIImage(named: "icons8-bus_stop")
//                            marker.icon = GMSMarker.markerImage(with: .blue)
                            marker.title = stop.name
                            marker.map = self.mapView
                        }
                        
                    }
                }
            }
        }
    }
}
