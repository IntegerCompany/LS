//
//  MenuViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 07.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit

protocol ContactWithFishViewDelegate {
    func logOut()
}
class MenuViewController: UIViewController {
    
    var delegate : ContactWithFishViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func logout(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
        delegate!.logOut()
    }
    @IBAction func settings(sender: UIButton) {
    }
    @IBAction func SAMI(sender: UIButton) {
    }
    @IBAction func tackleBox(sender: UIButton) {
    }
    @IBAction func recomend(sender: UIButton) {
    }
    @IBAction func report(sender: UIButton) {
    }
    @IBAction func terms(sender: UIButton) {
    }
    @IBAction func contactUS(sender: UIButton) {
    }
}
