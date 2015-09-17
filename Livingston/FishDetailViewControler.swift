//
//  FishDetailViewControler.swift
//  Livingston
//
//  Created by Max Vitruk on 04.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit

class FishDetailViewController : UIViewController {
    
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var note: UITextField!
    @IBOutlet weak var lenght: UITextField!
    
    var delegate : AcceptFishDetailDelegate?
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad(){
        super.viewDidLoad()

    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: UIButton) {
        let recFish = RecordedFish()
        if let uName = userDefaults.valueForKey("login") as? String {
            recFish.userName = uName
        }
        recFish.weight = self.weight.text!
        recFish.lenght = self.lenght.text!
        recFish.note = self.note.text!
        recFish.dateTime = NSDate()
        
        delegate?.acceptFishDetail(recFish)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
