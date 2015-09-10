//
//  TackleBoxViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 03.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit
import RealmSwift

class TackleBoxViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let realm = Realm()
    var tackleList = [LureData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "background")
        self.collectionView.backgroundColor = UIColor(patternImage: img!)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tackleList.removeAll(keepCapacity: false)
        var query = self.realm.objects(LureData)
        for item in query {
            tackleList.append(item as LureData)
        }
        println("\n\n Tackles count : \(tackleList.count)")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("fishGridViewCell", forIndexPath: indexPath) as! TackleCell
        let tackle = self.tackleList[indexPath.item]
        
        cell.name.text = tackle.LURE_NAME
        cell.activeSoundType.text = tackle.LURE_STYLE
        cell.type.text = tackle.LURE_WATER_TYPE
        
        getDataFromUrl(NSURL(fileURLWithPath: tackle.LURE_IMAGE_URL)!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                cell.image.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    
}
//Delegate
extension TackleBoxViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProgramUIViewController") as! ProgramUIViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

