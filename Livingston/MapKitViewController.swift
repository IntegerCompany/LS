//
//  MapKitViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 12.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapKitViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    let geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! ContactViewController
        vc.delegate = self
    }
    
    private func moveTo(address : String){
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                self.map.addAnnotation(MKPlacemark(placemark: placemark))
                let center = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.map.setRegion(region, animated: true)
            }
        })
    }
    
    private func getStringFromArrayItem(sender : NSDictionary)->String{
        let adr = sender["Address1"] as? String
        let city = sender["City"] as? String
        let state = sender["State"] as? String
        let zip = sender["Zip"] as? String
        let country = sender["Country"] as? String
        return "\(adr), \(city), \(state), \(zip), \(country)"
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
extension MapKitViewController : SendDataToMapKitDelegate {
    func sendShopDataToMap(sender : NSArray){
        let item = sender.firstObject as! NSDictionary
        self.moveTo(self.getStringFromArrayItem(item))
    }
    func shopDidSelectedOnMap(sender : NSDictionary){
        self.moveTo(self.getStringFromArrayItem(sender))
    }
}
extension MapKitViewController : MKMapViewDelegate {
    
}
