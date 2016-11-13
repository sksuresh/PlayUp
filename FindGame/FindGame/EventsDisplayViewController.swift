//
//  EventsDisplayViewController.swift
//  FindGame
//
//  Created by SureshDokula on 12/11/16.
//  Copyright © 2016 MDTMAC. All rights reserved.
//

import Foundation
import UIKit
import MapKit
class EventsDisplayViewController : UIViewController {
    @IBOutlet var mapview:MKMapView!
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        centerMapOnLocation(initialLocation)
        loadInitialData()
        mapview.addAnnotations(artworks)
    

        mapview.delegate = self
        
        // show artwork on map
        //    let artwork = Artwork(title: "King David Kalakaua", locationName: "Waikiki Gateway Park",
        //      discipline: "Sculpture", coordinate: CLLocationCoordinate2D(latitude: 21.283921,
        //        longitude: -157.831661))
        //    mapview.addAnnotation(artwork)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
   @IBAction func menuclicked(){
        self.tabBarController?.selectedIndex = 3
    }
    
    
    @IBAction func newSchedule(sender:AnyObject){
        let storyBoard = UIStoryboard(name: "Schedule", bundle: NSBundle.mainBundle())
        let event:NewEventViewController? =  storyBoard.instantiateViewControllerWithIdentifier("NewEvent") as? NewEventViewController
        self.navigationController?.pushViewController(event!, animated: true)
        
    }

    
    var artworks = [Artwork]()
    func loadInitialData() {
        // 1
        let fileName = NSBundle.mainBundle().pathForResource("PublicArt", ofType: "json");
        var readError : NSError?
        var data: NSData = try! NSData(contentsOfFile: fileName!, options: NSDataReadingOptions(rawValue: 0))
        
        // 2
        var error: NSError?
        let jsonObject: AnyObject!
        do {
            jsonObject = try NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions(rawValue: 0))
        } catch let error1 as NSError {
            error = error1
            jsonObject = nil
        }
        
        // 3
        if let jsonObject = jsonObject as? [String: AnyObject] where error == nil,
            // 4
            let jsonData = JSONValue.fromObject(jsonObject)?["data"]?.array {
                for artworkJSON in jsonData {
                    if let artworkJSON = artworkJSON.array,
                        // 5
                        artwork = Artwork.fromJSON(artworkJSON) {
                            artworks.append(artwork)
                    }
                }
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapview.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - location manager to authorize user location for Maps app
    //  var locationManager = CLLocationManager()
    //  func checkLocationAuthorizationStatus() {
    //    if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
    //      mapview.showsUserLocation = true
    //    } else {
    //      locationManager.requestWhenInUseAuthorization()
    //    }
    //  }
    //  
    //  override func viewDidAppear(animated: Bool) {
    //    super.viewDidAppear(animated)
    //    checkLocationAuthorizationStatus()
    //  }
}

extension EventsDisplayViewController:MKMapViewDelegate {
    // 1
    func mapView(mapView: MKMapView,
        viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
            if let annotation = annotation as? Artwork {
                let identifier = "pin"
                var view: MKPinAnnotationView
                if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                    as? MKPinAnnotationView { // 2
                        dequeuedView.annotation = annotation
                        view = dequeuedView
                } else {
                    // 3
                    view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view.canShowCallout = true
                    view.calloutOffset = CGPoint(x: -5, y: 5)
                    view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                }
                
                view.pinColor = annotation.pinColor()
                
                return view
            }
            return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Artwork
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
   
}