//
//  DetailCatchLog.swift
//  Livingston
//
//  Created by Max Vitruk on 18.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import RealmSwift

class DetailCatchLogViewController : UITableViewController {
    
    
    let cellId = "DetailCatchLogCell"
    var recordedFish  = [RecordedFish]()
    var realm : Realm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            self.realm = try Realm()
            let query = self.realm.objects(RecordedFish)
            for item in query {
                recordedFish.append(item as RecordedFish)
                print(item)
            }
            self.tableView.reloadData()
        }catch{
            print("Cant intitialize data base !")
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordedFish.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! DetailCatchLogCell
        let index = indexPath.row
        let item = recordedFish[index]
        cell.number.text = "\(index + 1)"
        cell.anglerName.text = item.userName
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        cell.date.text = dateFormatter.stringFromDate(NSDate())
        cell.weight.text = item.weight
        cell.lenght.text = item.lenght
        cell.note.text = item.note
        if item.image.length > 0 {
            cell.fishImage.image = UIImage(data: item.image)
        }

        return cell
    }
}
