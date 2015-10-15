//
//  AddLureViewController.swift
//  Livingston
//
//  Created by Dmytro Lohush on 10/15/15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import RealmSwift
import AssetsLibrary

class AddLureViewController: UIViewController {
  
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var image: UIButton!
  @IBOutlet weak var waterType: UITextField!
  var imageUrl : NSURL?
  var realm:Realm!
  var isCamera = false
  
  // MARK: - Button`s actions
  @IBAction func addPhoto(sender: AnyObject) {
    
    let alert = UIAlertController(title: "Upload/Take a Picture", message: "Choose an option", preferredStyle: UIAlertControllerStyle.Alert)
    
    alert.addAction(UIAlertAction(title: "Open Gallery", style: .Default, handler: {
      action in self.getPhotoFromGallery("Open Gallery")
    }))
    alert.addAction(UIAlertAction(title: "Take a Picture", style: .Default, handler: {
      action in self.getPhotoFromGallery("Take a Picture")
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  @IBAction func save(sender: UIButton) {
    if(name.text?.characters.count != 0){
      
      let lureInfo = LureData()
      
      lureInfo.LURE_ITEM_CODE = ""
      lureInfo.LURE_CODE = ""
      lureInfo.LURE_NAME = self.name.text!
      if let waterType = self.waterType.text{
        lureInfo.LURE_WATER_TYPE = waterType
      }else{
        lureInfo.LURE_WATER_TYPE = ""
      }
      if let imageUrl = self.imageUrl{
        lureInfo.LURE_IMAGE_URL = imageUrl.absoluteString
        print("Path :\(imageUrl.path!)")
      }
      lureInfo.LURE_UUID = ""
      lureInfo.LURE_SOUND = ""
      
      do {
        try self.realm.write({
          //THIS IS DATA BASE WRITE
          self.realm.add(lureInfo)
          self.navigationController?.popViewControllerAnimated(true)
        })
      }catch _ {
        print("Cant write to data base !")
      }
      
    }else{
      let alert = UIAlertController(title: "Error", message: "Name can not be empty", preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: "ОК", style: .Default, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    do {
      self.realm = try Realm()
    }catch _ {
      print("Cant initi data base !")
    }
  }
  
  
}

//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension AddLureViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func getPhotoFromGallery(string: String) {
    
    let picker = UIImagePickerController()
    picker.delegate = self // skatolyk: that why we need UINavigationControllerDelegate, UINavigationBarDelegate protocols
    picker.allowsEditing = false
    
    if string == "Open Gallery" {
      isCamera = false
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
      }
    } else {
      isCamera = true
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
        picker.sourceType = UIImagePickerControllerSourceType.Camera
      }
    }
    self.presentViewController(picker, animated: true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//    print("imageUrl =\(self.imageUrl!)")
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      
      self.image.setBackgroundImage(pickedImage, forState: .Normal)
      
      if(isCamera){
        ALAssetsLibrary().writeImageToSavedPhotosAlbum(pickedImage.CGImage, orientation: ALAssetOrientation(rawValue: pickedImage.imageOrientation.rawValue)!,
          completionBlock:{ (path:NSURL!, error:NSError!) -> Void in
            print("\(path)")
            self.imageUrl = path
            //Here you will get your path
        })
      }else{
         self.imageUrl = info[UIImagePickerControllerReferenceURL] as? NSURL;
      }     
      
      dismissViewControllerAnimated(true, completion: nil)
      
    }
  }
}

