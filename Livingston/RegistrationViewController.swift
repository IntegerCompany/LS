//
//  RegistrationViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 04.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {

    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    
    let regUrl = "http://appapi.livingstonlures.com/Register.php"
    let segueID = "makeARegistration"
//    "Username"
//    "Password"
//    "Date"
    override func viewDidLoad() {
        super.viewDidLoad()
        stylePlaceHolder()
    }
    @IBAction func register(sender: UIButton) {
        if checkTextFields() {
            let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            
            let username = self.login.text
            let pwd = self.password.text
            let params = "Username=\(username)&Password=\(pwd)&Date=\(timestamp)"
            print("\n\n\(params)")
            registrationTask(params)
        }else {
            print("Validate your registration data !")
        }
    }
    @IBAction func back(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func checkTextFields() -> Bool{
        return self.login.text!.characters.count >= 2 && self.password.text!.characters.count >= 4 && (self.password.text == self.confirmPassword.text)
    }
    
    func makeARegisterInTask(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        userDefaults.setValue(self.login.text, forKey: "login")
        userDefaults.setValue(self.password.text, forKey: "password")
        userDefaults.setValue(timestamp, forKey: "date")
        userDefaults.synchronize()
        
        self.progress.stopAnimating()
        
        self.performSegueWithIdentifier(self.segueID, sender: self)
    }
    func badRegistrationTask(){
        self.progress.stopAnimating()
        print("Bad registration information")
    }
    func registrationTask(postString : String){
        self.progress.startAnimating()
        let request = NSMutableURLRequest(URL: NSURL(string: self.regUrl)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            print("response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Registration responce  = \(responseString)")
            
            if let id = responseString?.integerValue {
                if id > 0 {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.makeARegisterInTask()
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.badRegistrationTask()
                    });
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.badRegistrationTask()
                });
            }
        }
        task.resume()
    }
    
    func stylePlaceHolder(){
        self.login.attributedPlaceholder = NSAttributedString(string:self.login.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        self.password.attributedPlaceholder = NSAttributedString(string:self.password.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        self.confirmPassword.attributedPlaceholder = NSAttributedString(string:self.confirmPassword.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        
        self.progress.hidesWhenStopped = true
    }

}
