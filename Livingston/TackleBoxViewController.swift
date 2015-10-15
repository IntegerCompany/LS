//
//  TackleBoxViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 03.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit
import RealmSwift
import AssetsLibrary

class TackleBoxViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let segueID = "showProgramUI"
    
    var realm : Realm!
    var tackleList = [LureData]()
    
    let imgUrl = "http://appapi.livingstonlures.com/lure_photos/"

    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            self.realm = try Realm()
        }catch{
            print("Cant intitialize data base !")
        }
        
        let img = UIImage(named: "background")
        self.collectionView.backgroundColor = UIColor(patternImage: img!)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tackleList.removeAll(keepCapacity: false)
        let query = self.realm.objects(LureData)
        for item in query {
            tackleList.append(item as LureData)
        }
        print("\n\n Tackles count : \(tackleList.count)")
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func record(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RecordACatchViewController") as! RecordACatchViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func back(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueID {
            let vc = segue.destinationViewController as! ProgramUIViewController
            let tackle = sender as! LureData
            vc.lureData = tackle
        }
    }

    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
}
//Data source
extension TackleBoxViewController : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tackleList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("fishGridViewCell", forIndexPath: indexPath) as! TackleCell
        let tackle = self.tackleList[indexPath.item]
        
        cell.name.text = tackle.LURE_NAME
        cell.activeSoundType.text = tackle.LURE_STYLE
        cell.type.text = tackle.LURE_WATER_TYPE
        
        let lureID = tackle.LURE_ITEM_CODE
        print("\n\(lureID)")
        let lureImgUrl = imgUrl + "\(lureID).png"
        
        print("\(tackle.LURE_IMAGE_URL)")
        let url = NSURL(string: lureImgUrl)
      
      if(tackle.LURE_IMAGE_URL.characters.count != 0){
        getImageFromPath(tackle.LURE_IMAGE_URL, onComplete: { (image) -> Void in
          cell.image.image = image
        })
      }else{
        self.getDataFromUrl(url!) { data in
          dispatch_async(dispatch_get_main_queue()) {
            cell.image.image = UIImage(data: data!)
          }
        }
      }
        return cell
    }
  
   func getImageFromPath(path: String, onComplete:((image: UIImage?) -> Void)) {
    let assetsLibrary = ALAssetsLibrary()
    let url = NSURL(string: path)!
    assetsLibrary.assetForURL(url, resultBlock: { (asset) -> Void in
      onComplete(image: UIImage(CGImage: asset.defaultRepresentation().fullResolutionImage().takeUnretainedValue()))
      }, failureBlock: { (error) -> Void in
        onComplete(image: nil)
    })
  }
  
}
//Delegate
extension TackleBoxViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tackle = self.tackleList[indexPath.item]
        self.performSegueWithIdentifier(segueID, sender: tackle)
    }
}

