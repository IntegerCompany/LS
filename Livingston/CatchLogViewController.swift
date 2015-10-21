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
    let sgueIDList = "goCatchDetailList"
    var realm : Realm!
    var catchCount  = 0
    var catchTotalWeight = 0
    var avarageWeight = 0
    var catchLureFished = 0
    var lureNames = [String]()
    var uniqLure = [RecordedFish]()
    
    let rowName = ["Catches","Total weight", "Max Weight", "Catch locations", "Miles fished", "Lure fished "]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            self.realm = try Realm()
            let query = self.realm!.objects(RecordedFish)
            catchCount = query.count
            for rec in query {
                if let weight = Int(rec.weight){
                    self.catchTotalWeight += weight
                    if avarageWeight < weight {
                        avarageWeight = weight
                    }
                }
                if !lureNames.contains(rec.lureName){
                    uniqLure.append(rec)
                }
                self.catchLureFished = uniqLure.count
            }

            
        }catch _ {
            print("cant Innitialize Data base")
        }

        
        dateText.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
    }
    @IBAction func stopFishing(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func uniq<S: SequenceType, E: Hashable where E==S.Generator.Element>(source: S) -> [E] {
        var seen: [E:Bool] = [:]
        return source.filter { seen.updateValue(true, forKey: $0) == nil }
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
        var totalText  = ""
        switch index {
        case 0 :
            totalText = "\(self.catchCount)"
            break
        case 1 :
            totalText = "\(self.catchTotalWeight)"
            break
        case 2 :
            totalText = "\(self.avarageWeight)"
            break
        case 5 :
            totalText = "\(self.catchLureFished)"
            break
        default:
            break
        }
        cell.infoTotalText.text = totalText
        return cell
    }
}
