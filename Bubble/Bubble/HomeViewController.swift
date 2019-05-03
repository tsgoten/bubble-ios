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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.setCenter(<#T##coordinate: CLLocationCoordinate2D##CLLocationCoordinate2D#>, animated: true)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBOutlet weak var mapView: MKMapView!
}
