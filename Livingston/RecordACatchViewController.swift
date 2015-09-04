//
//  RecordACatchViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 03.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit
import RealmSwift

class RecordACatchViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var lastLureFish: UIImageView!
    
    var popoverContent : FishDetailViewController?
    let realm = Realm()
    var recordedFish : RecordedFish = RecordedFish()
    var imageToSave : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("FishDetailViewController") as? FishDetailViewController
        popoverContent?.delegate = self
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
            self.recordedFish.image = UIImagePNGRepresentation(self.imageToSave)
        }
        
        self.realm.write({ //THIS IS DATA BASE WRITE
            self.realm.add(self.recordedFish)
        })
        println("Detail has been added to DB !")
        let fishInDB = self.realm.objects(RecordedFish)
        println("\n Items in DATABASE : \(count(fishInDB))") //HERE WE SHOW HOW MANY ITEMS IN DATA BASE
        
    }
    
    func showDetailView() {
        popoverContent!.modalPresentationStyle = UIModalPresentationStyle.Popover
        popoverContent!.preferredContentSize = CGSizeMake(240,280)
        let nav = popoverContent!.popoverPresentationController
        nav?.delegate = self
        nav?.sourceView = self.view
        let yPosition = self.view.center.y + 180.0
        nav?.sourceRect = CGRectMake(self.view.center.x, yPosition , 0, 0)
        self.navigationController?.presentViewController(popoverContent!, animated: true, completion: nil)
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
}
//Pop up window callback
extension RecordACatchViewController : AcceptFishDetailDelegate {
    
    func acceptFishDetail(sender: Object) {
        println("Get info from pop up window !")
        self.recordedFish = sender as! RecordedFish
    }
}

extension RecordACatchViewController : GetCameraImageDelegate {
    
    func didRecievePhotoFromCamera(image: UIImage) {
        self.imageToSave = image
    }
}

