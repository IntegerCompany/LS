//
//  RecomendationController.swift
//  Livingston
//
//  Created by Max Vitruk on 27.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit

class RecomendationController : BaseViewController {
    
    @IBOutlet weak var secondLureImage: UIImageView!
    @IBOutlet weak var firstLureImage: UIImageView!
    
    @IBOutlet weak var firstLureText3: UILabel!
    @IBOutlet weak var firstLureText2: UILabel!
    @IBOutlet weak var firstLureText: UILabel!
    
    @IBOutlet weak var secondLureText3: UILabel!
    @IBOutlet weak var secondLureText: UILabel!
    @IBOutlet weak var secondLureText2: UILabel!
    
    let imgUrl = "http://appapi.livingstonlures.com/lure_photos/"
    let tacklesDict = ["Stick Master" :"0801","B4 Venom 8":"5085"]
    
    var locationManager:CLLocationManager!
    var locationStatus : String = ""
    
    //Title = Stick Master
    //Code = 0801
    
    //Title = B4 Venom 8
//    Code = 5085

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startTrackingLocation()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.uploadHardCodeImgz()
    }
    
    func startTrackingLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func updateWeatherConditions(lon : Double, lat : Double){
        //http://api.wunderground.com/api/834b4357b2ba37d2//conditions/q/37.776289,-122.395234.json
        
        let urlStr = "http://api.wunderground.com/api/834b4357b2ba37d2//conditions/q/\(lat),\(lon).json"
        let searchURL = NSURL(string: urlStr)!
        print(searchURL)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(searchURL, completionHandler: {data, response, error -> Void in
            
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    
                    print(jsonResult)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        let conditions = jsonResult["current_observation"] as! NSDictionary
                        let temperature = conditions["temperature_string"] as? String
                        let weather = conditions["weather"] as? String
                        print(weather)
                        self.locationManager.stopUpdatingLocation()
//                        self.temperature.text = temperature
                        //MARK : Hardcode
                    });
//                    
//                    print("Success: \(self.temperature)")
                } else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                    dispatch_async(dispatch_get_main_queue(), {
//                        self.temperature.text = "?"
                    });
                    
                }
            } catch let parseError {
                print(parseError)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could get JSON: '\(jsonStr)'")
                dispatch_async(dispatch_get_main_queue(), {
//                    self.temperature.text = "?"
                });
                
            }
        })
        task.resume()
        
    }
    
    func uploadHardCodeImgz(){
        let lureImgUrl = imgUrl + "2502.png"
        uploadImages(self.firstLureImage, surl: lureImgUrl)
        let lureImgUrl2 = imgUrl + "2603.png"
        uploadImages(self.secondLureImage, surl: lureImgUrl2)
    }
    
    func uploadImages(into : UIImageView , surl : String){
        print(surl)
        let url = NSURL(string: surl)
        self.getDataFromUrl(url!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                into.image = UIImage(data: data!)
            }
        }
    }
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }

}

extension RecomendationController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        updateWeatherConditions(coord.longitude,lat: coord.latitude)
        print(coord.latitude)
        print(coord.longitude)
    }
    
    // authorization status
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
        switch status {
        case CLAuthorizationStatus.Restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.Denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.NotDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
        if (shouldIAllow == true) {
            NSLog("Location to Allowed")
            // Start location services
            self.locationManager.startUpdatingLocation()
        } else {
            NSLog("Denied access: \(locationStatus)")
        }
    }
}
