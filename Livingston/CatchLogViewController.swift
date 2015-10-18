//
//  CatchLogViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 18.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit

class CatchLogViewController : BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateText: UILabel!
    
    let cellId = "CatchLogCell"
    let segueID = "goDelailCatclog"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            //ewewa
            break
        default :
            break
        }
    }
}
extension CatchLogViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! CatchLogCell
        return cell
    }
}
