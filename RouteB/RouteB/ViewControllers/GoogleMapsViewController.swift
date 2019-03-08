//
//  GoogleMapsViewController.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/28/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import UIKit
import GoogleMaps

//additions: get bus arrival time for each stop. can find arrival info in bus live info but there is no connection to specific bus stops

class GoogleMapsViewController: UIViewController {

    var myRoute : UserRoute?
    var mapView: GMSMapView?
    var statusColor: UIColor?
    var advisoryMessages: [[String]]?
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
        statusButton()
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
    
    
    func statusButton() {
        let customButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        customButton.setTitle(" Status ", for: .normal)
        customButton.setTitleColor(.black, for: .normal)
        customButton.backgroundColor = statusColor
        customButton.layer.cornerRadius = 4.0
        customButton.layer.masksToBounds = true
        customButton.addTarget(self, action: #selector(statusButtonClicked), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customButton)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    @objc func statusButtonClicked() {
        
        guard let messages = advisoryMessages else {
            print("Advisory message is nil")
            let alertController = UIAlertController(title: "There are no issues currently with this route.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            present(alertController, animated: true)
            return}
        var newStr = ""
        for message in messages {
            newStr += "-\(message[0])" + "\n"
        }
        print("this is the new string: \(newStr)")
        if messages.isEmpty {
            let alertController = UIAlertController(title: "There are no issues currently with this route.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        } else {
            let alertController = UIAlertController(title: "Route info:", message: newStr, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
        
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
        
        let bounds = GMSCoordinateBounds.init(coordinate: startingLocation, coordinate: endingLocation)
        mapView?.moveCamera(GMSCameraUpdate.fit(bounds))
    }
    func timer() {
        let myTimer = Timer(timeInterval: 20.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        RunLoop.main.add(myTimer, forMode: RunLoop.Mode.default)
    }
    @objc func refresh() {
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
            let busLat = bus.MonitoredVehicleJourney.VehicleLocation.Latitude
            let busLon = bus.MonitoredVehicleJourney.VehicleLocation.Longitude
            let coordinate = CLLocationCoordinate2D.init(latitude: busLat, longitude: busLon)
            let marker = GMSMarker(position: coordinate)
            marker.title = bus.MonitoredVehicleJourney.VehicleRef
            marker.snippet = "direction: \(bus.MonitoredVehicleJourney.DirectionRef)"
            marker.icon = GMSMarker.markerImage(with: .purple)
            allMarkers.append(marker)
            DispatchQueue.main.async {
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
