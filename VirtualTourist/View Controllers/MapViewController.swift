//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by akhil mantha on 23/08/18.
//  Copyright © 2018 akhil mantha. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: CoreDataViewController {
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapVisibleRegionFromDefaults()
        loadSavedPins()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveMapVisibleRegionToDefaults()
    }
    
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in:mapView)
            
            let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            let annot = PinAnnotation()
            
            annot.coordinate = touchMapCoordinate;
            
            mapView.addAnnotation(annot)
            
            addNewPin(pinAnnotation: annot)
        }
    }
    
    private func addNewPin(pinAnnotation:PinAnnotation){
        
        let newPin = Pin(pinAnnotation: pinAnnotation, context: fetchedResultsController!.managedObjectContext)
        pinAnnotation.associatedPin = newPin
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        do {
            try stack.saveContext()
        }catch {
            print("Error while saving in addNewPin")
        }
        
        
    }
    
    private func loadSavedPins(){
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        for pin in (fetchedResultsController?.fetchedObjects)! {
            
            let pin = pin as! Pin
            
            let annot = PinAnnotation()
            
            annot.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            
            annot.associatedPin = pin
            
            mapView.addAnnotation(annot)
            
        }
        
    }
}


extension MapViewController : MKMapViewDelegate {
    
    // MARK : Annotation Functions
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        let reuseId = "pin"
        
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            setupPinView(pinView: pinView!)
            
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        mapView.deselectAnnotation(view.annotation, animated: false)
        performSegue(withIdentifier: "ShowPhotos", sender: view)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "ShowPhotos" {
            
            if let photosVC = segue.destination as? PhotoViewController {
                
                // Create Fetch Request
                let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
                
                fr.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
                
                let selectedPin = ((sender as! MKAnnotationView).annotation as! PinAnnotation).associatedPin
                
                let pred = NSPredicate(format: "pin = %@", argumentArray: [selectedPin!])
                
                fr.predicate = pred
                
                // Create FetchedResultsController
                let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext:fetchedResultsController!.managedObjectContext, sectionNameKeyPath:nil, cacheName: nil)
                
                // Inject it into the notesVC
                photosVC.fetchedResultsController = fc
                
                // Inject the notebook too!
                photosVC.selectedPin = selectedPin
            }
        }
    }
    
    
    private func setupPinView(pinView:MKPinAnnotationView) {
        pinView.canShowCallout = false
        pinView.pinTintColor = UIColor.red
        pinView.animatesDrop = true
    }
    
    
    fileprivate func setupMapVisibleRegionFromDefaults(){
        
        guard let centerLatitude = UserDefaults.standard.value(forKey: UserDefaultsConstants.MapViewCenterLatitudeKey) as? CLLocationDegrees else {
            return
        }
        
        guard let centerLongitude = UserDefaults.standard.value(forKey: UserDefaultsConstants.MapViewCenterLongitudeKey) as? CLLocationDegrees else {
            return
        }
        
        guard let regionLatitudeDelta = UserDefaults.standard.value(forKey: UserDefaultsConstants.MapViewRegionLatitudeDeltaKey) as? CLLocationDistance else {
            return
        }
        
        guard let regionLongitudeDelta = UserDefaults.standard.value(forKey: UserDefaultsConstants.MapViewRegionLongitudeDeltaKey) as? CLLocationDistance else {
            return
        }
        
        let centerCoords = CLLocationCoordinate2DMake(centerLatitude, centerLongitude)
        let span = MKCoordinateSpanMake(regionLatitudeDelta, regionLongitudeDelta)
        let region = MKCoordinateRegionMake(centerCoords, span)
        
        mapView.setRegion(region, animated: true)
    }
    
    fileprivate func saveMapVisibleRegionToDefaults(){
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: UserDefaultsConstants.MapViewCenterLatitudeKey)
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: UserDefaultsConstants.MapViewCenterLongitudeKey)
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: UserDefaultsConstants.MapViewRegionLatitudeDeltaKey)
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: UserDefaultsConstants.MapViewRegionLongitudeDeltaKey)
        UserDefaults.standard.synchronize()
    }
    
}

