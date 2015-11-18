//
//  FishViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 03.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import RealmSwift

class FishViewController: BaseViewController {
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var contentMain: UIView!
  @IBOutlet weak var homView: UIView!
  @IBOutlet weak var contentUGotIt: UIView!
  
  @IBOutlet weak var userName: UILabel!
  @IBOutlet weak var logDate: UILabel!
  
  @IBOutlet weak var menu: UIButton!
  
  @IBOutlet weak var myLocation: UILabel!
  @IBOutlet weak var temperature: UILabel!
  
  @IBOutlet weak var nearestPlace: UILabel!
  @IBOutlet weak var lastLureName: UILabel!
  @IBOutlet weak var lastBluetreuse: UILabel!
  @IBOutlet weak var lastActiveSound: UILabel!
  @IBOutlet weak var lastLureImage: UIImageView!
  
  let imgUrl = "http://appapi.livingstonlures.com/lure_photos/"
  
  var locationManager:CLLocationManager!
  var locationStatus : String = ""
  
  var realm : Realm?
  var needShowCatchLogSreen = false
  
  
  override func viewDidLoad() {
    print("viewDidLoad")
    super.viewDidLoad()
    self.navigationController?.navigationBarHidden = false
    
    if needShowCatchLogSreen{
      showCatchLogScreen()
      print("showing catchlog")
    }else{
      do {
        self.realm = try Realm()
      }catch _ {
        print("Cant initi data base !")
      }
      
      //start updating locatios
      self.startTrackingLocation()
      
      //Updating User name and log date
      let userDefaults = NSUserDefaults.standardUserDefaults()
      
      if let uName = userDefaults.valueForKey("login") as? String {
        self.userName.text = uName
      }
      if let lDate = userDefaults.valueForKey("date") as? String {
        self.logDate.text = lDate
      }
      self.improveTextInformation()
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    print("viewDidAppear")
  }
  
  override func viewWillAppear(animated: Bool) {
    print("viewWillAppear")
    let query = self.realm!.objects(RecordedFish)
    let lureQuery = self.realm!.objects(LureData)
    
    if(query.count != 0){
      let lName = query[query.count - 1].lureName
      lastLureName.text = lName
      if let pathmp3 = NSBundle.mainBundle().pathForResource("SoundsMP3", ofType: "plist") {
        
        let soundsMP3 = NSArray(contentsOfFile: pathmp3)!
        
        for lure in lureQuery where lure.LURE_NAME == lName {
          let lureID = lure.LURE_ITEM_CODE
          let lureImgUrl = imgUrl + "\(lureID).png"
          let url = NSURL(string: lureImgUrl)
          
          if(lure.LURE_CODE.characters.count == 0){
            TackleBoxViewController.getImageFromPath((lure.LURE_IMAGE_URL), onComplete: { (image) -> Void in
              self.lastLureImage.image = image
            })
          }else{
            ProgramUIViewController.getDataFromUrl(url!) { data in
              dispatch_async(dispatch_get_main_queue()) {
                self.lastLureImage.image = UIImage(data: data!)
              }
            }
          }
          
        }
        
        guard let soundNumber = Int(query[query.count - 1].lureSound) else {
          self.lastActiveSound.text = soundsMP3[0] as? String
          return
        }
        let soundName = soundsMP3[soundNumber] as! String
        self.lastActiveSound.text = soundName
        
      }
      
    }
  }
  
  @IBAction func record(sender: UIButton) {
    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RecordACatchViewController") as! RecordACatchViewController
    self.navigationController?.pushViewController(vc, animated: true)    }
  
  @IBAction func startFishing(sender: UIButton) {
    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RecordACatchViewController") as! RecordACatchViewController
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  @IBAction func uGotIt(sender: UIButton) {
    self.contentMain.hidden = true
    self.contentMain.userInteractionEnabled = false
    
    self.contentUGotIt.hidden = false
    self.contentUGotIt.userInteractionEnabled = true
  }
  
  func showCatchLogScreen(){
    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CatchLogViewController") as! CatchLogViewController
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func startTrackingLocation(){
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  func setUsersClosestCity(location : CLLocation){
    let geoCoder = CLGeocoder()
    geoCoder.reverseGeocodeLocation(location)
      {
        (placemarks, error) -> Void in
        
        let placeArray = placemarks as [CLPlacemark]!
        
        // Place details
        var placeMark: CLPlacemark!
        placeMark = placeArray?[0]
        // Address dictionary
        //print(placeMark.addressDictionary)
        
        // Location name
        if let state = placeMark.addressDictionary?["State"] as? NSString
        {
          if let city = placeMark.addressDictionary?["City"] as? NSString {
            self.myLocation.text = "\(state), \(city)"
            self.locationManager.stopUpdatingLocation()
          }
        }
        if let lDate = self.userDefaults.valueForKey("date") as? String {
          self.logDate.text = lDate
        }
        
        self.improveTextInformation()
    }
  }
  
  func improveTextInformation(){
    
    let title = NSMutableAttributedString()
    let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)]
    let l1 = NSMutableAttributedString(string:"START FISHING!\n\n", attributes:attrs)
    let l2 = NSMutableAttributedString(string: "Each time you opn this app , you'll need to tap ")
    let l3 = NSMutableAttributedString(string: "START \nFISHING",attributes:attrs)
    let l3a = NSMutableAttributedString(string: " to begin logging data for the day.\n\n")
    let l4 = NSMutableAttributedString(string: "When you're done fishing for the day, tap " )
    let l5 = NSMutableAttributedString(string: "STOP \nFISHING",attributes:attrs)
    let l5a = NSMutableAttributedString(string:" to stop logging data and power")
    let l6 = NSMutableAttributedString(string: "off your lures and if applicable, SAM devices.")
    
    title.appendAttributedString(l1)
    title.appendAttributedString(l2)
    title.appendAttributedString(l3)
    title.appendAttributedString(l3a)
    title.appendAttributedString(l4)
    title.appendAttributedString(l5)
    title.appendAttributedString(l5a)
    title.appendAttributedString(l6)
    
    self.textView.attributedText = title;
    self.textView.textAlignment = NSTextAlignment.Center
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
          
          dispatch_async(dispatch_get_main_queue(), {
            let conditions = jsonResult["current_observation"] as! NSDictionary
            let temperature = conditions["temperature_string"] as? String
            self.temperature.text = temperature
          });
          
          print("Success: \(self.temperature)")
        } else {
          let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
          print("Error could not parse JSON: \(jsonStr)")
          dispatch_async(dispatch_get_main_queue(), {
            self.temperature.text = "?"
          });
          
        }
      } catch let parseError {
        print(parseError)
        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
        print("Error could get JSON: '\(jsonStr)'")
        dispatch_async(dispatch_get_main_queue(), {
          self.temperature.text = "?"
        });
        
      }
    })
    task.resume()
    
  }
  
  func getJSONfromAPI(latitude latitude : Double, longitude : Double){
    let urlPath = "https://maps.googleapis.com/maps/api/place/radarsearch/json?location=\(latitude),\(longitude)&radius=5000&types=keyword=fishing+spots+near+me&key=AIzaSyDLpW5rQH1Do6OKCR2fSyau8hWia0pviwg"
    let url: NSURL = NSURL(string: urlPath)!
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
      if error != nil {
        // If there is an error in the web request, print it to the console
        print(error!.localizedDescription)
      }
      
      do {
        let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
        print(jsonResult)
        let json = JSON(jsonResult)
        let lon = json["results"][0]["geometry"]["location"]["lng"].double!
        let lat = json["results"][0]["geometry"]["location"]["lat"].double!
        let location = CLLocation(latitude: lat, longitude: lon)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location)
          {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            // Address dictionary
            print(placeMark.addressDictionary)
            
            // Location name
            if let state = placeMark.addressDictionary?["State"] as? NSString
            {
              if let city = placeMark.addressDictionary?["City"] as? NSString {
                self.nearestPlace.text = "\(state), \(city)"
              }
            }
        }
      }catch{
        print("FishViewController : Error in getJSONfromAPI func")
      }
    })
    task.resume()
  }
}

extension FishViewController : CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.setUsersClosestCity(locations.last!)
    let locationArray = locations as NSArray
    let locationObj = locationArray.lastObject as! CLLocation
    let coord = locationObj.coordinate
    getJSONfromAPI(latitude: coord.latitude,longitude: coord.longitude)
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