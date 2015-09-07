//
//  ProgramUIViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 03.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit
import CoreBluetooth

class ProgramUIViewController: UIViewController,CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var programText: UILabel!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var syncButton: UIButton!
    
    @IBOutlet weak var battery: UILabel!
    
    let LureServiceReadId = CBUUID(string: "0000180a-0000-1000-8000-00805f9b34fb")
    let LureCharId = CBUUID(string: "00002a24-0000-1000-8000-00805f9b34fb")
    
    let LureServicePlaySoundId = CBUUID(string: "18bd1003-5770-4e53-b034-e998f80a5e43")
    let LureCarPlayDefault = CBUUID(string: "18bd1005-5770-4e53-b034-e998f80a5e43")
    let LureCarChangeSound = CBUUID(string: "18bd1006-5770-4e53-b034-e998f80a5e43")
    
    let LureServiceBatteryID = CBUUID(string: "0000180f-0000-1000-8000-00805f9b34fb")
    let LureCarReadBatary = CBUUID(string: "00002a19-0000-1000-8000-00805f9b34fb")
    
    var centralManager:CBCentralManager!
    var blueToothReady = false
    var sensorTagPeripheral:CBPeripheral!
    
    var lureData : LureData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startUpCentralManager()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //update lure info data !
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func record(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RecordACatchViewController") as! RecordACatchViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func back(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func tackle(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TackleBoxViewController") as! TackleBoxViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func centralManagerDidUpdateState(central: CBCentralManager!){
        switch (central.state) {
        case .PoweredOff:
            statusText.text = "CoreBluetooth BLE hardware is powered off"
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
        case .PoweredOn:
            statusText.text = "Ready"
            blueToothReady = true;
            
        case .Resetting:
            statusText.text = "CoreBluetooth BLE hardware is resetting"
            
        case .Unauthorized:
            statusText.text = "CoreBluetooth BLE state is unauthorized"
            
        case .Unknown:
            statusText.text = "CoreBluetooth BLE state is unknown"
            
        case .Unsupported:
            statusText.text = "CoreBluetooth BLE hardware is unsupported on this platform"
            
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
//        foundBLE.textColor = UIColor.redColor()
//        foundBLE.text = "Connected to: \(peripheral.name)"
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        if let data = self.lureData {
            if peripheral.name ==  data.LURE_NAME {
                println("\n\nDiscovered !")
                centralManager.connectPeripheral(peripheral, options: nil)
                self.sensorTagPeripheral = peripheral
            }
        }
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
        
        self.programText.text = "Connected"
        
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
            self.programText.text = "Lure name : \(lureName)"
            println("Lure name : \(lureName)")
        }
    }
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        self.programText.text = "Disconnected"
        central.scanForPeripheralsWithServices(nil, options: nil)
    }

}
//Data source
extension ProgramUIViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("soundCell", forIndexPath: indexPath) as! UITableViewCell
        return cell
    }
}
//Delegate
extension ProgramUIViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
