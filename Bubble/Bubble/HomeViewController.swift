//
//  HomeViewController.swift
//  Bubble
//
//  Created by Tarang Srivastava on 5/3/19.
//  Copyright © 2019 Bubble. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        //mapView.setCenter(currentLocation, animated: true)
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            mapView.setCenter((locationManager.location?.coordinate)!, animated: true)
        }
        
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
    @IBOutlet weak var mapView: MKMapView!
}
