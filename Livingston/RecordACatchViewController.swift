//
//  RecordACatchViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 03.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation

class RecordACatchViewController: BaseViewController {

    @IBOutlet weak var recordDate: UILabel!
    @IBOutlet weak var myLocation: UILabel!
    @IBOutlet weak var lastLureFish: UIImageView!
    
    var popoverContent2 : FishDetailViewController?
    var realm : Realm?
    var recordedFish : RecordedFish = RecordedFish()
    var imageToSave : UIImage?
    
    var locationManager: CLLocationManager!
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set date !
        do{
            self.realm = try Realm()
        }catch _ {
            print("cant Innitialize Data base")
        }
        
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        self.recordDate.text = timestamp
         
        popoverContent2 = self.storyboard?.instantiateViewControllerWithIdentifier("FishDetailViewController") as? FishDetailViewController
        popoverContent2?.delegate = self
        
        self.initLocationManager()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToCamera" {
            let cvc = segue.destinationViewController as! CameraViewController
            cvc.delegate = self
        }
    }
    @IBAction func addMoreDetails(sender: UIButton) {
        self.showDetailView()
    }
    
    //Saving into data base
    @IBAction func submitRecord(sender: UIButton) {
        if self.imageToSave != nil {
            self.recordedFish.image = UIImagePNGRepresentation(self.imageToSave!)!
        }
        do{
            try self.realm!.write({ //THIS IS DATA BASE WRITE
                self.realm!.add(self.recordedFish)
            })
        }catch _ {
            print("Cant add detain into db")
        }
        
        print("Detail has been added to DB !")
        let fishInDB = self.realm!.objects(RecordedFish)
        print("\n Items in DATABASE : \(fishInDB.count)") //HERE WE SHOW HOW MANY ITEMS IN DATA BASE
        
    }
    @available(iOS 8.0, *)
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        // function code
    }
    
    func showDetailView() {
        popoverContent2!.modalPresentationStyle = UIModalPresentationStyle.Popover
        popoverContent2!.preferredContentSize = CGSizeMake(240,280)
        let nav = popoverContent2!.popoverPresentationController
        nav?.delegate = self
        nav?.sourceView = self.view
        let yPosition = self.view.center.y + 180.0
        nav?.sourceRect = CGRectMake(self.view.center.x, yPosition , 0, 0)
        self.navigationController?.presentViewController(popoverContent2!, animated: true, completion: nil)
        
    }
    
    // Location Manager helper stuff
    func initLocationManager() {
        seenError = false
        locationFixAchieved = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
    }

    
}

extension RecordACatchViewController : CLLocationManagerDelegate {
    // Location Manager Delegate stuff
    // If failed
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        if (seenError == false) {
            seenError = true
            print(error, terminator: "")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            let locationArray = locations as NSArray
            let locationObj = locationArray.lastObject as! CLLocation
            let coord = locationObj.coordinate
            
            print(coord.latitude)
            print(coord.longitude)
            
            self.myLocation.text = "Lat: \(coord.latitude), Lon : \(coord.longitude)"
        }
    }
    
    // authorization status
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
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
                locationManager.startUpdatingLocation()
            } else {
                NSLog("Denied access: \(locationStatus)")
            }
    }
}
//Pop up window callback
extension RecordACatchViewController : AcceptFishDetailDelegate {
    
    func acceptFishDetail(sender: AnyObject) {
        print("Get info from pop up window !")
        self.recordedFish = sender as! RecordedFish
    }
}

extension RecordACatchViewController : GetCameraImageDelegate {
    
    func didRecievePhotoFromCamera(image: UIImage) {
        self.imageToSave = image
    }
}

