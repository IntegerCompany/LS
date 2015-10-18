//
//  ContactViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 11.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit

protocol SendDataToMapKitDelegate {
    func sendShopDataToMap(sender : NSArray)
    func shopDidSelectedOnMap(sender : NSDictionary)
}
class ContactViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    
    let url = "http://appapi.livingstonlures.com/Dealers.php"
    var selectedRowIndex: NSIndexPath?
    var contactList = NSArray()
    var filteredList = [AnyObject]()
    var delegate : SendDataToMapKitDelegate?
    
    var popoverSortContent : SortContactsPopViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.hidden = true
        self.progress.hidesWhenStopped = true
        self.getJSON(self.url)
        // Do any additional setup after loading the view.
        
        let filter = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: "sortContactPopMenu:")
        self.navigationItem.rightBarButtonItem = filter
        
        popoverSortContent = self.storyboard?.instantiateViewControllerWithIdentifier("SortContactsPopViewController") as! SortContactsPopViewController
        popoverSortContent.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.filteredList.removeAll()
        self.tableView.reloadData()
    }
    func sortContactPopMenu(sender : UIBarButtonItem){
        popoverSortContent!.modalPresentationStyle = UIModalPresentationStyle.Popover
        popoverSortContent!.preferredContentSize = CGSizeMake(200,200)
        let nav = popoverSortContent!.popoverPresentationController
        nav?.delegate = self
        nav?.sourceView = self.view
        nav?.permittedArrowDirections = UIPopoverArrowDirection.Up
        nav?.sourceRect = CGRectMake(400 , 60 , 0, 0)
        self.navigationController?.presentViewController(popoverSortContent!, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    func getJSON(urlPath : String) {
        self.progress.startAnimating()
        let url : NSString = urlPath
        let urlStr : NSString = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let searchURL : NSURL = NSURL(string: urlStr as String)!
        print(searchURL)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(searchURL, completionHandler: {data, response, error -> Void in
            
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    let success = json["success"] as? Int                                  // Okay, the `json` is here, let's get the value for 'success' out of it
                    let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    //print(jsonResult)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.contactList = jsonResult["Main"] as! [(NSArray)]
                        self.tableView.hidden = false
                        self.tableView.reloadData()
                        self.progress.stopAnimating()
                        
                        if self.delegate != nil {
                            self.delegate?.sendShopDataToMap(self.contactList)
                        }
                    });

                    print("Success: \(success)")
                } else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)    // No error thrown, but not NSDictionary
                    print("Error could not parse JSON: \(jsonStr)")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.progress.startAnimating()
                    });
                    
                }
            } catch let parseError {
                print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                dispatch_async(dispatch_get_main_queue(), {
                    self.progress.startAnimating()
                });
                
            }
        })
        task.resume()
    }

}

//Data source
extension ContactViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if filteredList.count == 0 {
            return contactList.count
        }else{
            return filteredList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DealerList", forIndexPath: indexPath) as! DealerList
        var item : NSDictionary!
        if filteredList.count == 0 {
            item = contactList[indexPath.row] as! NSDictionary
        }else{
            item = filteredList[indexPath.row] as! NSDictionary
        }
        print(item)
        
        cell.shopName.text = item["Company"] as? String
        let adr = item["Address1"] as? String
        cell.adress.text = "Address : " + adr!
        let city = item["City"] as? String
        cell.city.text = "City : " + city!
        let state = item["State"] as? String
        cell.state.text = "State : " + state!
        let zip = item["Zip"] as? String
        cell.zip.text = "Zip : " + zip!
        let country = item["Country"] as? String
        cell.country.text = "Country : " + country!
        let phone = item["Phone1"] as? String
        cell.Phone.text = "Phone : " + phone!
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == selectedRowIndex {
            return DealerList.expandedHeight
        } else {
            return DealerList.defaultHeight
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! DealerList).watchFrameChanges()
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! DealerList).ignoreFrameChanges()
    }
}
//Delegate
extension ContactViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let previousIndex = self.selectedRowIndex
        //update map from MapKitController
        if delegate != nil{
            self.delegate?.shopDidSelectedOnMap(self.contactList[indexPath.row] as! NSDictionary)
        }
        if indexPath == selectedRowIndex {
            selectedRowIndex = nil
        }else{
            selectedRowIndex = indexPath
        }
        
        var indexes : Array<NSIndexPath> = []
        if let previous = previousIndex {
            indexes += [previous]
        }
        
        if let current = selectedRowIndex {
            indexes += [current]
        }
        
        if indexes.count > 0 {
            tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
}

extension ContactViewController : SortContactSelectedDelegate {
    func sortMenuItemSelected(selectedItem: SortCOntactItem){
        
    }
    
    func searchByCharters(searchStrig : String){

        for item in contactList {
            let dictItem = item as! NSDictionary
            let address = dictItem["Address1"] as! String
            if address.containsString(searchStrig){
                self.filteredList.append(item)
            }
        }
        self.tableView.reloadData()
    }
    func cancelSortFiltes(){
        self.filteredList.removeAll()
        self.tableView.reloadData()
    }
}

