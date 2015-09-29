//
//  DiscoveringBluetoothController.swift
//  Livingston
//
//  Created by Max Vitruk on 04.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit
import CoreBluetooth
import RealmSwift

class DiscoveringBluetoothController: BaseViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet var coreBluetooth: UILabel!
    @IBOutlet var discoveredDevices: UILabel!
    @IBOutlet var foundBLE: UILabel!
    @IBOutlet var connected: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progress: UIActivityIndicatorView!

    let serviceUUID = CBUUID(string: "0000180a-0000-1000-8000-00805f9b34fb")
    let charateristicUUID = CBUUID(string: "00002a24-0000-1000-8000-00805f9b34fb")
//    let serviceUUID = CBUUID(string: "Device Information")
//    let charateristicUUID = CBUUID(string: "Manufacturer Name String")

    let URL = "http://appapi.livingstonlures.com/Lure.php"
    var peripheralUUIDString = ""
    
    var centralManager:CBCentralManager!
    var blueToothReady = false
    var sensorTagPeripheral:CBPeripheral!
    var indicator: UIActivityIndicatorView?
    var lureInfo = LureData()
    
    var realm : Realm!
    
    var peripheralList : [CBPeripheral] = [CBPeripheral]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            self.realm = try Realm()
        }catch _ {
            print("Cant initi data base !")
        }
        
        self.progress.startAnimating()
        startUpCentralManager()
        initLoadingDialog()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProgramController" {
            let vc = segue.destinationViewController as! ProgramUIViewController
            vc.lureData = sender as? LureData
        }
    }
    
    @IBAction func backButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func centralManagerDidUpdateState(central: CBCentralManager){
        switch (central.state) {
        case .PoweredOff:
            coreBluetooth.text = "CoreBluetooth BLE hardware is powered off"
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
        case .PoweredOn:
            coreBluetooth.text = "CoreBluetooth BLE hardware is powered on and ready"
            blueToothReady = true;
            
        case .Resetting:
            coreBluetooth.text = "CoreBluetooth BLE hardware is resetting"
            
        case .Unauthorized:
            coreBluetooth.text = "CoreBluetooth BLE state is unauthorized"
            
        case .Unknown:
            coreBluetooth.text = "CoreBluetooth BLE state is unknown"
            
        case .Unsupported:
            coreBluetooth.text = "CoreBluetooth BLE hardware is unsupported on this platform"
            
        }
        if blueToothReady {
            discoverDevices()
        }
    }
    
    func startUpCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        self.centralManager.state
    }
    func discoverDevices() {
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    func centralManager(central: CBCentralManager,didConnectPeripheral peripheral: CBPeripheral)
    {
        sensorTagPeripheral.delegate = self
        sensorTagPeripheral.discoverServices(nil)
        print("\nConnected to \(peripheral.name)")
        foundBLE.textColor = UIColor.redColor()
        foundBLE.text = "Connected to: \(peripheral.name)"
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        discoveredDevices.text = "Discovered: \(peripheral.name) : RSSI \(RSSI) "
        print("\nDiscovered: \(peripheral.name) : RSSI \(RSSI) ")
        print("\nUUID : \(peripheral.identifier.UUIDString) ")
        
        if self.peripheralList.contains(peripheral) {
            print("\nlist already contains this peripheral item")
        }else{
            if peripheral.name != "nil" {
                self.peripheralList.append(peripheral)
                print("\nAdd \(peripheral.identifier.UUIDString) to list ")
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func scanBLE(sender: UIButton) {
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func connectingPeripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!)
    {
        print("\nServices \(sensorTagPeripheral.services)")
    }
    
    /******* CBCentralPeripheralDelegate *******/
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        var isThatServiceHere :Bool = false
        for service in peripheral.services! {
            let thisService = service 
            if service.UUID == self.serviceUUID {
                print("\nINFO :  Did discover service : \(self.serviceUUID) ")
                // Discover characteristics of LureServiceReadId
                peripheral.discoverCharacteristics(nil, forService: thisService)
                isThatServiceHere = true
            }
            // Uncomment to print list of UUIDs
            print("\nServices UUID : \(thisService.UUID)")
        }
        if !isThatServiceHere {
            self.presentAlert("Can't discover lure data with Lure service ID !")
            print("Can't discover lure data with Lure service ID !")
        }
    }
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // 0x01 data byte to enable sensor
        var enableValue = 1
        _ = NSData(bytes: &enableValue, length: sizeof(UInt8))
        
        var isCharHere = false
        // check the uuid of each characteristic to find config and data characteristics
        for charateristic in service.characteristics! {
            let thisCharacteristic = charateristic 
            print("\ncharateristic.UUID : \(thisCharacteristic.UUID)")
            // check for data characteristic
            if thisCharacteristic.UUID == self.charateristicUUID {
                // Enable Sensor Notification
                print("\nINFO : Reading Value from characteristic : \(charateristicUUID) ")
                self.sensorTagPeripheral.readValueForCharacteristic(thisCharacteristic)
                isCharHere = true
                
            }
        }
        if !isCharHere {
            self.presentAlert("Can't discover lure data with Characteristic ID !")
            print("Can't discover lure data with Characteristic ID !")
        }
    }
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        self.discoveredDevices.text = "Connected with peripheral :\(characteristic.UUID)"
        print("\nConnected with peripheral : \(characteristic.UUID) with \(self.charateristicUUID)")
        
        if characteristic.UUID == charateristicUUID {
            print("\nINFO : Find a characterisctc with id \(charateristicUUID)")
            // Convert NSData to array of signed 16 bit values
            let data = characteristic.value
            var values = [UInt8](count:data!.length, repeatedValue:0)
            data!.getBytes(&values, length:data!.length)
            
            if let lureName = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
                print(lureName)
                let postString = "LureCode=\(lureName)"
                self.discoveredDevices.text = "Lure name : \(lureName)"
                print("\n\nLure name : \(lureName)")
                //MARK : Make a post request
                self.gettingLureInfoTask(postString)
            } else {
                print("\nnot a valid UTF-8 sequence")
                self.presentAlert("\n\nLure name has not detected!")
                
                print("\n\nLure name has not detected !")
            }
        }
    }
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        self.discoveredDevices.text = "Disconnected"
        central.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    //Post request witch takes a lure information.
    //See Models.swift 
    func gettingLureInfoTask(postString : String){
        self.indicator?.startAnimating()
        let request = NSMutableURLRequest(URL: NSURL(string: URL)!)
        
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    let success = json["success"] as? Int                                  // Okay, the `json` is here, let's get the value for 'success' out of it
                    dispatch_async(dispatch_get_main_queue(), {
                        self.parseLureDataWithWithJSON(json)
                        self.indicator?.stopAnimating()
                    });
                    print("Success: \(success)")
                } else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)    // No error thrown, but not NSDictionary
                    print("Error could not parse JSON: \(jsonStr)")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.indicator?.stopAnimating()
                    });

                }
            } catch let parseError {
                print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                dispatch_async(dispatch_get_main_queue(), {
                    self.indicator?.stopAnimating()
                });

            }
        }
        
        task.resume()
    }
    
    //Go back to tackle list with passing data to.
    
    func parseLureDataWithWithJSON(json : NSDictionary) {
        let imgUrl = "www.someurl.com/images/"
        
        let lureObj = json["Lure"] as! NSDictionary
        let LURE_ITEM_CODE = lureObj["0"] as! String
        let LURE_CODE = lureObj["2"] as! String
        let LURE_NAME = lureObj["1"] as! String
        let LURE_WATER_TYPE = lureObj["4"] as! String
        let LURE_STYLE = lureObj["5"] as! String
        let LURE_IMAGE_URL = imgUrl + LURE_NAME + ".png"
    
        lureInfo.LURE_ITEM_CODE = LURE_ITEM_CODE
        lureInfo.LURE_CODE = LURE_CODE
        lureInfo.LURE_NAME = LURE_NAME
        lureInfo.LURE_WATER_TYPE = LURE_WATER_TYPE
        lureInfo.LURE_IMAGE_URL = LURE_IMAGE_URL
        lureInfo.LURE_UUID = peripheralUUIDString
    
        let alermassage = "Lure code : \(LURE_ITEM_CODE)\n" + "Lure name : \(LURE_NAME)\n" + "Lure water type : \(LURE_WATER_TYPE)\n"
        
        let createAccountErrorAlert: UIAlertView = UIAlertView()
        
        createAccountErrorAlert.delegate = self
        
        createAccountErrorAlert.title = "Save this tackle ?"
        createAccountErrorAlert.message = alermassage
        createAccountErrorAlert.addButtonWithTitle("OK")
        createAccountErrorAlert.addButtonWithTitle("Cancel")
        createAccountErrorAlert.dismissWithClickedButtonIndex(1, animated: false)
        
        createAccountErrorAlert.show()
        
    }
    //MARK : ALER view delegate
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        switch buttonIndex{
            
        case 1:
            NSLog("Cancel");
            break;
        case 0:
            NSLog("OK");
            do {
                try self.realm.write({
                    //THIS IS DATA BASE WRITE
                    self.realm.add(self.lureInfo)
                })
            }catch _ {
                print("Cant write to data base !")
            }
            let fishInDB = self.realm.objects(RecordedFish)
            print("LureInfo has been added to DB !")
            print("\n Items in DATABASE : \(fishInDB.count)")
            
            self.centralManager.stopScan()
            self.centralManager.cancelPeripheralConnection(sensorTagPeripheral)
            self.navigationController?.popViewControllerAnimated(true)
            
            break;
        default:
            NSLog("Default");
            break;
            //Some code here..
        }
    }
    
    func initLoadingDialog(){
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.indicator!.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        self.indicator!.center = view.center
        view.addSubview(indicator!)
        self.indicator!.bringSubviewToFront(view)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func presentAlert(message : String){
        let alert = UIAlertController(title: "Alert", message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
//Data source
extension DiscoveringBluetoothController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripheralList.count
//        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BLECell", forIndexPath: indexPath) as! BLECell
        cell.name.text = peripheralList[indexPath.row].name
//
//        cell.name.text = "TEST"
        
        return cell
    }
}
//Delegate
extension DiscoveringBluetoothController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Stop scanning
        self.centralManager.stopScan()
        // Set as the peripheral to use and establish connection
        let peripheral = self.peripheralList[indexPath.row]
        self.peripheralUUIDString = peripheral.identifier.UUIDString
        self.sensorTagPeripheral = peripheral
        self.centralManager.connectPeripheral(peripheral, options: nil)
        print("\ncentralManager.connectPeripheral\n")
//        self.gettingLureInfoTask("LureCode=DEMO 26")
        
    }
}


