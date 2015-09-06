//
//  DiscoveringBluetoothController.swift
//  Livingston
//
//  Created by Max Vitruk on 04.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit
import CoreBluetooth

class DiscoveringBluetoothController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet var coreBluetooth: UILabel!
    @IBOutlet var discoveredDevices: UILabel!
    @IBOutlet var foundBLE: UILabel!
    @IBOutlet var connected: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progress: UIActivityIndicatorView!

    let LureServiceReadId = CBUUID(string: "0000180a-0000-1000-8000-00805f9b34fb")
    let LureCharId = CBUUID(string: "00002a24-0000-1000-8000-00805f9b34fb")
    
    var centralManager:CBCentralManager!
    var blueToothReady = false
    var sensorTagPeripheral:CBPeripheral!
    
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
            println("yes")
        }else{
            self.peripheralList.append(peripheral)
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
    }
}


