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
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: UIButton) {
        
    }
    
}
