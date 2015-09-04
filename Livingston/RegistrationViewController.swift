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
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var registerButton: UIButton!
    
    let regUrl = "http://appapi.livingstonlures.com/Register.php"
    let segueID = "makeARegistration"
//    "Username"
//    "Password"
//    "Date"
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    @IBAction func register(sender: UIButton) {
        if checkTextFields() {
            let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            
            let username = self.login.text
            let pwd = self.password.text
            var params = ["Username":username, "Password":pwd, "Date":timestamp] as Dictionary<String, String>
            post(params, url: self.regUrl)
        }else {
            println("Validate your registration data !")
        }
    }
    @IBAction func back(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func checkTextFields() -> Bool{
        return count(self.login.text) >= 2 && count(self.password.text) >= 4 && (self.password.text == self.confirmPassword.text)
    }
    
    func makeARegisterInTask(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        userDefaults.setValue(self.login.text, forKey: "login")
        userDefaults.setValue(self.password.text, forKey: "password")
        userDefaults.setValue(timestamp, forKey: "date")
        userDefaults.synchronize()
        
        self.performSegueWithIdentifier(self.segueID, sender: self)
    }

    
    func post(params : Dictionary<String, String>, url : String) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var success = parseJSON["success"] as? Int
                    println("Succes: \(success)")
                    println("\(parseJSON)")
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.makeARegisterInTask()
            });
        })
        
        task.resume()
    }

}
