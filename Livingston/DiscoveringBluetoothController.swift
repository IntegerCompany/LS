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

class DiscoveringBluetoothController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet var coreBluetooth: UILabel!
    @IBOutlet var discoveredDevices: UILabel!
    @IBOutlet var foundBLE: UILabel!
    @IBOutlet var connected: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progress: UIActivityIndicatorView!

    let LureServiceReadId = CBUUID(string: "0000180a-0000-1000-8000-00805f9b34fb")
    let LureCharId = CBUUID(string: "00002a24-0000-1000-8000-00805f9b34fb")
    let URL = "http://appapi.livingstonlures.com/Lure.php"
    
    var centralManager:CBCentralManager!
    var blueToothReady = false
    var sensorTagPeripheral:CBPeripheral!
    var lureName : String!
    
    let realm = Realm()
    
    var peripheralList : [CBPeripheral] = [CBPeripheral]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progress.startAnimating()
        startUpCentralManager()
    }
    
    @IBAction func backButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func centralManagerDidUpdateState(central: CBCentralManager!){
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
    func centralManager(central: CBCentralManager!,didConnectPeripheral peripheral: CBPeripheral!)
    {
        sensorTagPeripheral.delegate = self
        sensorTagPeripheral.discoverServices(nil)
        println("Connected")
        foundBLE.textColor = UIColor.redColor()
        foundBLE.text = "Connected to: \(peripheral.name)"
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        discoveredDevices.text = "Discovered: \(peripheral.name) : RSSI \(RSSI) "
        println("Discovered: \(peripheral.name) : RSSI \(RSSI) ")
        println("UUID : \(peripheral.identifier.UUIDString) ")
        
        if contains(self.peripheralList, peripheral) {
            println("list already contains this peripheral item")
        }else{
            self.peripheralList.append(peripheral)
            println("list already contains this peripheral item")
            self.tableView.reloadData()
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
        println("Services \(sensorTagPeripheral.services)")
    }
    
    /******* CBCentralPeripheralDelegate *******/
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        for service in peripheral.services {
            let thisService = service as! CBService
            if service.UUID == LureServiceReadId {
                // Discover characteristics of IR Temperature Service
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
            // Uncomment to print list of UUIDs
            println(thisService.UUID)
        }
    }
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        // 0x01 data byte to enable sensor
        var enableValue = 1
        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        
        // check the uuid of each characteristic to find config and data characteristics
        for charateristic in service.characteristics {
            let thisCharacteristic = charateristic as! CBCharacteristic
            // check for data characteristic
            if thisCharacteristic.UUID == LureCharId {
                // Enable Sensor Notification
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
        }
    }
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        self.discoveredDevices.text = "Connected"
        
        if characteristic.UUID == LureCharId {
            // Convert NSData to array of signed 16 bit values
            let dataBytes = characteristic.value
            let dataLength = dataBytes.length
            var dataArray = [Int16](count: dataLength, repeatedValue: 0)
            dataBytes.getBytes(&dataArray, length: dataLength * sizeof(Int16))
            
            // Element 1 of the array will be ambient temperature raw value
            let ambientTemperature = Double(dataArray[1])/128
            
            // Display on the temp label
            let lureName = NSString(format: "%.2f", ambientTemperature) as String
            self.discoveredDevices.text = "Lure name : \(lureName)"
            println("Lure name : \(lureName)")
        }
    }
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        self.discoveredDevices.text = "Disconnected"
        central.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    //Post request witch takes a lure information.
    //See Models.swift 
    
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
                    
                    //Call back to main thread !
                    dispatch_async(dispatch_get_main_queue(), {
                        self.backToTackleList(parseJSON)
                    });
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
    }
    
    //Go back to tackle list with passing data to.
    func backToTackleList(json : NSDictionary){
        
        self.parseLureDataWithWithJSON(json)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func parseLureDataWithWithJSON(json : NSDictionary) {
        
        let LURE_ITEM_CODE = json["LURE_ITEM_CODE"] as! String
        let LURE_CODE = json["LURE_CODE"] as! String
        let LURE_NAME = json["LURE_NAME"] as! String
        let LURE_WATER_TYPE = json["LURE_WATER_TYPE"] as! String
        let LURE_STYLE = json["LURE_STYLE"] as! String
        let LURE_IMAGE_URL = json["LURE_IMAGE_URL"] as! String
        
        var lureInfo = LureData()
        lureInfo.LURE_ITEM_CODE = LURE_ITEM_CODE
        lureInfo.LURE_CODE = LURE_CODE
        lureInfo.LURE_NAME = LURE_NAME
        lureInfo.LURE_WATER_TYPE = LURE_WATER_TYPE
        lureInfo.LURE_ITEM_CODE = LURE_ITEM_CODE
        lureInfo.LURE_IMAGE_URL = LURE_IMAGE_URL
        
        self.realm.write({ //THIS IS DATA BASE WRITE
            self.realm.add(lureInfo)
        })
        
        println("LureInfo has been added to DB !")
        let fishInDB = self.realm.objects(RecordedFish)
        println("\n Items in DATABASE : \(count(fishInDB))")
        
    }
}
//Data source
extension DiscoveringBluetoothController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripheralList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("BLECell", forIndexPath: indexPath) as! BLECell
        cell.name.text = peripheralList[indexPath.row].name
        
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
        self.sensorTagPeripheral = peripheral
        self.centralManager.connectPeripheral(peripheral, options: nil)
        println("centralManager.connectPeripheral\n")
        
        if self.lureName != nil {
            var params = ["LureCode":self.lureName] as Dictionary<String, String>
            //MARK : Make a post request
            post(params, url: self.URL)
        }else{
            println("\n\nLure name has not detected !")
        }
        
    }
}


