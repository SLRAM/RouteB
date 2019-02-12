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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTableView.dataSource = self
        createTableView.delegate = self

        
        getCoordinate(addressString: address) { (foundAddress, error) in
            if let _ = error {
                return
            }
            let foundAddressLat = foundAddress.latitude,
            foundAddressLong = foundAddress.longitude
            print("lat: \(foundAddressLat) long: \(foundAddressLong)")
        }
    }
    
    private func saveRoute()-> Route? {
        //add found address lat long here
        guard let startingAddress = startingAddressField.text,
        let endingAddress = endingAddressField.text else {return nil}
        let savedRoute = transportationArray
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.dateStyle = DateFormatter.Style.long
//        formatter.timeStyle = .medium
//        let timestamp = formatter.string(from: date)
        let route = Route.init(startingAddress: startingAddress, endingAddress: endingAddress, transportation: savedRoute)
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
