//
//  ContactViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 11.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit

class ContactViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let url = "http://appapi.livingstonlures.com/Dealers.php"
    var selectedRowIndex: NSIndexPath = NSIndexPath(forRow: -1, inSection: 0)
    var contactList = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getJSON(self.url)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getJSON(urlPath : String) {
        var url : NSString = urlPath
        var urlStr : NSString = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var searchURL : NSURL = NSURL(string: urlStr as String)!
        println(searchURL)
        let session = NSURLSession.sharedSession()
        
        var error:NSError?
        
        let task = session.dataTaskWithURL(searchURL, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                println(error!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            var err: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            
            //println("\(jsonResult)")
            if err != nil {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.contactList = jsonResult["Main"] as! [(NSArray)]
                    self.tableView.reloadData()
                });
            }
        })
        task.resume()
    }

}

//Data source
extension ContactViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("DealerList", forIndexPath: indexPath) as! DealerList
        let item = contactList[indexPath.row] as! NSDictionary
        
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
    
}
//Delegate
extension ContactViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

