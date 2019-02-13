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
    let address = "89 Metropolitan Oval Bronx NY"
    @IBOutlet weak var startingAddressField: UITextField!
    @IBOutlet weak var endingAddressField: UITextField!
    @IBOutlet weak var transportationField: UITextField!
    @IBOutlet weak var createTableView: UITableView!
    @IBOutlet weak var addTransportButton: UIButton!
    var transportationArray = [String]()
    var startingAddressLat = Double()
    var startingAddressLong = Double()
    var endingAddressLat = Double()
    var endingAddressLong = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTableView.dataSource = self
        createTableView.delegate = self

        
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
        print(startingAddressField.text)
        print(endingAddressField.text)
        guard let startingAddress = startingAddressField.text,
        let endingAddress = endingAddressField.text else {return nil}
        
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
        getCoordinate(addressString: endingAddress) { (foundAddress, error) in
            if let _ = error {
                return
            }
            self.endingAddressLat = foundAddress.latitude
            self.endingAddressLong = foundAddress.longitude
//            print("lat: \(foundAddressLat) long: \(foundAddressLong)")
        }
        
        
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
        let controller = SearchTableViewController()
        controller.modalPresentationStyle = .popover
        return true
    }
    
}

extension CreateRouteViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transportationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = createTableView.dequeueReusableCell(withIdentifier: "MyCreateTableViewCell", for: indexPath) as? MyCreateTableViewCell else {return UITableViewCell()}
        print(transportationArray[indexPath.row].description)
        let route = transportationArray[indexPath.row]
        cell.createdLabel.text = route
        return cell
    }
    
    
}
