//
//  SyncLureViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 10.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit

class SyncLureViewController: BaseViewController {
  
  @IBAction func addLure(sender: UIButton) {
    self.performSegueWithIdentifier("addLure", sender: self)

  }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
}
