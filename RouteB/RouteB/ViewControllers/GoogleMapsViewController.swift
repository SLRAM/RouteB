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
    var advisoryMessages: [String]?
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
        print("advisoryMessages: \(advisoryMessages)")
        guard let busesUnwrapped = myRoute?.transportation else {return}
        buses = busesUnwrapped
//        setupView()
        timer()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setupView()
        loadBusRouteAndActiveOnRoute()

    }
    
    func setupView() {
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
//        let startingLocation = CLLocationCoordinate2D(latitude: startingLat, longitude: startingLong)
//        let endingLocation = CLLocationCoordinate2D(latitude: endingLat,longitude: endingLong)

        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6)
        mapView = GMSMapView.init(frame: CGRect.zero, camera: camera)
        self.view = mapView
        
        let startingLocation = CLLocationCoordinate2DMake(startingLat, startingLong)
        let endingLocation = CLLocationCoordinate2DMake(endingLat, endingLong)
        
        let startingMarker = GMSMarker.init()
        startingMarker.position = startingLocation
        startingMarker.title = "Starting"
        startingMarker.map = mapView
        
        let endingMarker = GMSMarker.init()
        endingMarker.position = endingLocation
        endingMarker.title = "ending"
        endingMarker.map = mapView
        
        
        let vancouver = CLLocationCoordinate2DMake(49.26, -123.11);
        let calgary = CLLocationCoordinate2DMake(51.05, -114.05);
        
        let vancouverMarker = GMSMarker.init()
        vancouverMarker.position = vancouver
        vancouverMarker.title = "Vancouver"
        vancouverMarker.map = mapView
        
        let calgaryMarker = GMSMarker.init()
        calgaryMarker.position = calgary
        calgaryMarker.title = "Calgary"
        calgaryMarker.map = mapView
        
        
        
        let bounds = GMSCoordinateBounds.init(coordinate: startingLocation, coordinate: endingLocation)
        mapView?.moveCamera(GMSCameraUpdate.fit(bounds))
        
        
        
        
        
        
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
        
        MTAAPIClient.getBusInfo(advisoryMessage: false, buses: buses) { (adivsoryMessage, activeBuses) in
            if let activeBuses = activeBuses {
                DispatchQueue.main.async {
                    self.setupMarkers(activeBuses: activeBuses)
                }
            }
        }
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
                            polyline.map = self.mapView
                        }
                    }
                    let stops = data.references.stops
                    for stop in stops {
                        print(stop.name)
                        DispatchQueue.main.async {
                            let circleCenter = CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.lon)
                            let busStop = GMSCircle(position: circleCenter, radius: 15)
                            busStop.title = stop.name
                            busStop.fillColor = .green
                            busStop.map = self.mapView
                            
                            let stopMarker = GMSMarker.init(position: circleCenter)
                            stopMarker.snippet = busStop.title
                            stopMarker.opacity = 0
                            stopMarker.map = self.mapView
                        }
                    }
                }
            }
        }
    }
}
