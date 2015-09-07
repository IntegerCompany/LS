//
//  FishViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 03.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit

class FishViewController: UIViewController, UIPopoverPresentationControllerDelegate,ContactWithFishViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var homView: UIView!
    @IBOutlet weak var contentUGotIt: UIView!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var logDate: UILabel!
    
    @IBOutlet weak var menu: UIButton!
    
    var popoverContent : MenuViewController!
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("MenuViewController") as? MenuViewController
        popoverContent.delegate = self
        
        //Updating User name and log date
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let uName = userDefaults.valueForKey("login") as? String {
            self.userName.text = uName
        }
        if let lDate = userDefaults.valueForKey("date") as? String {
            self.logDate.text = lDate
        }
        
        self.improveTextInformation()
    }

    @IBAction func menu(sender: UIButton) {
        self.showMenu()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logOut(){
        println("\n\nlogOut")
        userDefaults.setBool(false, forKey: "rememberMe")
        self.performSegueWithIdentifier("backSegue", sender: self)
        
    }
    
    @IBAction func record(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RecordACatchViewController") as! RecordACatchViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tackle(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TackleBoxViewController") as! TackleBoxViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func startFishing(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RecordACatchViewController") as! RecordACatchViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func uGotIt(sender: UIButton) {
        self.contentMain.hidden = true
        self.contentMain.userInteractionEnabled = false
        
        self.contentUGotIt.hidden = false
        self.contentUGotIt.userInteractionEnabled = true
    }
    
    func improveTextInformation(){
        let l1 : NSString = "START FISHING!"
        let l2 : NSString = "Each time you opn this app , you'll need to tap"
        let l3 : NSString = "START FISHING to begin logging data for the day."
        let l4 : NSString = "When you're done fishing for the day,tap"
        let l5 : NSString = "STOP FISHING to stop logging data and power"
        let l6 : NSString = "off your lures and if applicable,SAM devices."
        let content : NSString = NSString(format: "%@\r%@\r%@\r\r\r\r%@\r%@\r%@", l1, l2,l3
            , l4, l5,l6)
        
        let title = NSMutableAttributedString(string: content as String)
        let font = UIFont.systemFontOfSize(16)
        title.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, title.length))
        
        self.textView.attributedText = title;
        self.textView.textAlignment = NSTextAlignment.Center
    }
    
    func showMenu() {
        popoverContent!.modalPresentationStyle = UIModalPresentationStyle.Popover
        popoverContent!.preferredContentSize = CGSizeMake(240,350)
        let nav = popoverContent!.popoverPresentationController
        nav?.delegate = self
        nav?.sourceView = self.view
        let xPosition = self.menu.frame.minX + 50
        let yPosition = self.menu.frame.minY + 55
        nav?.permittedArrowDirections = UIPopoverArrowDirection.Up
        nav?.sourceRect = CGRectMake(xPosition, yPosition , 0, 0)
        self.navigationController?.presentViewController(popoverContent!, animated: true, completion: nil)
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}