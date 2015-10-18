//
//  CatchLogViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 18.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import RealmSwift

class CatchLogViewController : BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateText: UILabel!
    
    let cellId = "CatchLogCell"
    let segueID = "goDelailCatclog"
    var realm : Realm!
    var catchCount  = 0
    
    let rowName = ["Catches","Total weight", "Average Weight", "Catch locations", "Miles fished", "Lure fished "]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            self.realm = try Realm()
            let query = self.realm!.objects(LureData)
            catchCount = query.count
        }catch _ {
            print("cant Innitialize Data base")
        }

        
        dateText.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
    }
    @IBAction func stopFishing(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension CatchLogViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0 :
            self.performSegueWithIdentifier(segueID, sender: self)
            break
        default :
            break
        }
    }
}
extension CatchLogViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowName.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! CatchLogCell
        let index = indexPath.row
        cell.logName.text = self.rowName[index]
        return cell
    }
}
