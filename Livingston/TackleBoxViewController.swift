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

class TackleBoxViewController: BaseViewController, SortMenuItemSelectedDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var popoverSortContent : SortMenuViewController!
    
    let segueID = "showProgramUI"
    
    var realm : Realm!
    var tackleList = [LureData]()
    var filteredTackleList = [LureData]()
    
    let imgUrl = "http://appapi.livingstonlures.com/lure_photos/"
    
    func sortMenuItemSelected(selectedItem: SortMenuItem) {
        switch selectedItem{
        case .SortByName :
            dismissViewControllerAnimated(true,completion: nil)
            tackleList.sortInPlace { (element1, element2) -> Bool in
                return element1.LURE_NAME < element2.LURE_NAME
            }
        case .SortByType :
            dismissViewControllerAnimated(true,completion: nil)
            tackleList.sortInPlace { (element1, element2) -> Bool in
                return element1.LURE_CODE > element2.LURE_CODE
            }
        case .Search :
            dismissViewControllerAnimated(true,completion: nil)
            searchBar.hidden = false
            filteredTackleList = tackleList
        }
        collectionView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popoverSortContent = self.storyboard?.instantiateViewControllerWithIdentifier("SortMenuViewController") as! SortMenuViewController
        popoverSortContent.delegate = self
        searchBar.delegate = self
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
    
    @IBAction func sortMenu(sender: UIButton) {
        popoverSortContent!.modalPresentationStyle = UIModalPresentationStyle.Popover
        popoverSortContent!.preferredContentSize = CGSizeMake(140,140)
        let nav = popoverSortContent!.popoverPresentationController
        nav?.delegate = self
        nav?.sourceView = self.view
        nav?.permittedArrowDirections = UIPopoverArrowDirection.Up
        nav?.sourceRect = CGRectMake(sender.bounds.midX, 100 , 0, 0)
        self.navigationController?.presentViewController(popoverSortContent!, animated: true, completion: nil)
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
        print("LURE IMG :\(lureImgUrl)")
        
        print("\(tackle.LURE_IMAGE_URL)")
        let url = NSURL(string: lureImgUrl)
        
        if(tackle.LURE_CODE.characters.count == 0){
            if tackle.LURE_IMAGE_URL.characters.count != 0{
                TackleBoxViewController.getImageFromPath(tackle.LURE_IMAGE_URL, onComplete: { (image) -> Void in
                    cell.image.image = image
                })
            }else{
                cell.image.image = nil
            }
            
        }else{
            self.getDataFromUrl(url!) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    cell.image.image = UIImage(data: data!)
                }
            }
        }
        return cell
    }
    
    class func getImageFromPath(path: String, onComplete:((image: UIImage?) -> Void)) {
        if(path.characters.count != 0){
            let assetsLibrary = ALAssetsLibrary()
            let url = NSURL(string: path)!
            assetsLibrary.assetForURL(url, resultBlock: { (asset) -> Void in
                onComplete(image: UIImage(CGImage: asset.defaultRepresentation().fullResolutionImage().takeUnretainedValue()))
                }, failureBlock: { (error) -> Void in
                    onComplete(image: nil)
            })
            
        }
    }
    
}
//Delegate
extension TackleBoxViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tackle = self.tackleList[indexPath.item]
        self.performSegueWithIdentifier(segueID, sender: tackle)
    }
}

extension TackleBoxViewController : UISearchBarDelegate{
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.hidden = true
        tackleList = filteredTackleList
        collectionView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count != 0{
            tackleList = filteredTackleList.filter( { (lure: LureData) -> Bool in
                return lure.LURE_NAME.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
            })
        }else{
            tackleList = filteredTackleList
        }
        collectionView.reloadData()
    }
    
}


