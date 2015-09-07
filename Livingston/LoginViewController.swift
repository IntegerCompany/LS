//
//  ViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 03.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    

    @IBOutlet weak var progress: UIActivityIndicatorView!
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rememberMe: UISwitch!
    
    let logUrl = "http://appapi.livingstonlures.com/LoginService.php"
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progress.hidesWhenStopped = true
        
        if let isRemembered = userDefaults.valueForKey("rememberMe") as? Bool {
            if isRemembered {
                let username = userDefaults.valueForKey("login") as! String
                let pwd = self.userDefaults.valueForKey("password") as! String
                self.login.text = username
                self.password.text = pwd
                let postString = "Username=\(username)&Password=\(pwd)"
                //login
                self.loginTask(postString)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func login(sender: UIButton) {
        if checkTextFields() {
            let username = self.login.text
            let pwd = self.password.text
            let postString = "Username=\(username)&Password=\(pwd)"
            //login
            self.loginTask(postString)
        }else{
            println("Validate your login or(and) password")
        }
    }
    func checkTextFields() -> Bool{
        return count(self.login.text) >= 2 && count(self.password.text) >= 4
    }
    
    func makeALogInTask(){
        
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        userDefaults.setValue(self.login.text, forKey: "login")
        userDefaults.setValue(self.password.text, forKey: "password")
        userDefaults.setValue(timestamp, forKey: "date")
        userDefaults.synchronize()
        
        self.performSegueWithIdentifier("makeALogin", sender: self)
        
        self.progress.stopAnimating()
    }
    
    func badLoginTask(){
        self.progress.stopAnimating()
    }
    
    func loginTask(postString : String){
        self.progress.startAnimating()
        let request = NSMutableURLRequest(URL: NSURL(string: self.logUrl)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            println("response = \(response)")
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("LoginResponce = \(responseString)")
            
            if let id = responseString?.integerValue {
                if id > 0 {
                    self.userDefaults.setInteger(id, forKey: "user_id")
                    self.userDefaults.synchronize()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.makeALogInTask()
                    });
                }else{
                    println("Wrong login or password")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.badLoginTask()
                    });
                }
            }else{
                println("Bad request ! Wrong login or password")
                dispatch_async(dispatch_get_main_queue(), {
                    self.badLoginTask()
                });
            }
        }
        task.resume()
    }
    
    @IBAction func rememberMeAction(sender: UISwitch) {
        if sender.on {
            userDefaults.setBool(true, forKey: "rememberMe")
        }else{
            userDefaults.setBool(false, forKey: "rememberMe")
        }
    }
}

