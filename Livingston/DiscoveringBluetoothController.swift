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
    
    var centralManager:CBCentralManager!
    var blueToothReady = false
    var connectingPeripheral:CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startUpCentralManager()
    }
    
    @IBAction func backButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func centralManagerDidUpdateState(central: CBCentralManager!){
        switch (central.state) {
        case .PoweredOff:
            coreBluetooth.text = "CoreBluetooth BLE hardware is powered off"
            
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
    }
    func discoverDevices() {
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    func centralManager(central: CBCentralManager!,didConnectPeripheral peripheral: CBPeripheral!)
    {
        connectingPeripheral.delegate = self
        connectingPeripheral.discoverServices(nil)
        println("Connected")
        foundBLE.textColor = UIColor.redColor()
        foundBLE.text = "Connected to: \(peripheral.name)"
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        discoveredDevices.text = "Discovered \(peripheral.name)"
        println("Discovered: \(peripheral.name)")
        centralManager.stopScan()
        
        if peripheral.name ==  "iPad" || peripheral.name ==  "Blank" {
            println("ok")
            centralManager.connectPeripheral(peripheral, options: nil)
            self.connectingPeripheral = peripheral
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
        println("Services \(connectingPeripheral.services)")
    }
}
