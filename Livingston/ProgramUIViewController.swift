//
//  ProgramUIViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 03.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit
import CoreBluetooth

class ProgramUIViewController: BaseViewController ,CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var programText: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let LureServicePlaySoundId = CBUUID(string: "18bd1003-5770-4e53-b034-e998f80a5e43")
    let LureCharPlayDefault = CBUUID(string: "18bd1005-5770-4e53-b034-e998f80a5e43")
    let LureCharChangeSound = CBUUID(string: "18bd1006-5770-4e53-b034-e998f80a5e43")
    
    let LureServiceBatteryID = CBUUID(string: "0000180f-0000-1000-8000-00805f9b34fb")
    let LureCharReadBatary = CBUUID(string: "00002a19-0000-1000-8000-00805f9b34fb")
    
    let programCell = "programCell"
    let imgUrl = "http://appapi.livingstonlures.com/lure_photos/"
    
    var centralManager:CBCentralManager!
    var blueToothReady = false
    var sensorTagPeripheral:CBPeripheral!
    
    var lureData : LureData?
    var changeSoundCharacteristic : CBCharacteristic?
    
    var delegate : ProgramCellDelagate?
    
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
    
    func centralManagerDidUpdateState(central: CBCentralManager){
        switch (central.state) {
        case .PoweredOff:
            programText.text = "CoreBluetooth BLE hardware is powered off"
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
        case .PoweredOn:
            programText.text = "Scanning"
            blueToothReady = true;
            
        case .Resetting:
            programText.text = "CoreBluetooth BLE hardware is resetting"
            
        case .Unauthorized:
            programText.text = "CoreBluetooth BLE state is unauthorized"
            
        case .Unknown:
            programText.text = "CoreBluetooth BLE state is unknown"
            
        case .Unsupported:
            programText.text = "CoreBluetooth BLE hardware is unsupported on this platform"
            
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
        print("\nProgramUI Connected to \(peripheral.name)")
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {

        print("\n ProgramUI Discovered: \(peripheral.name) : RSSI \(RSSI) ")
        print("\n ProgramUI UUID : \(peripheral.identifier.UUIDString) ")
        
        if peripheral.identifier.UUIDString == lureData?.LURE_UUID {
            self.sensorTagPeripheral = peripheral
            print("ProgramUI Did discover peripeheral \(peripheral.name)")
        }
    }
    
    func connectingPeripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!)
    {
        print("ProgramUI Services \(sensorTagPeripheral.services)")
    }
    
    /******* CBCentralPeripheralDelegate *******/
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        var isThatServiceHere :Bool = false
        for service in peripheral.services! {
            let thisService = service 
            if service.UUID == self.LureServicePlaySoundId {
                print("\nProgramUI INFO :  Did discover service : \(self.LureServicePlaySoundId) ")
                // Discover characteristics of LureServiceReadId
                peripheral.discoverCharacteristics(nil, forService: thisService)
                isThatServiceHere = true
                delegate!.connectionStatus(true)
            }
            if service.UUID == self.LureServiceBatteryID {
                print("\nProgramUI INFO :  Did discover service : \(self.LureServiceBatteryID) ")
                // Discover characteristics of LureServiceReadId
                peripheral.discoverCharacteristics(nil, forService: thisService)
                isThatServiceHere = true
                delegate!.connectionStatus(true)
            }
            // Uncomment to print list of UUIDs
            print("\nProgramUI Services UUID : \(thisService.UUID)")
        }
        if !isThatServiceHere {
            self.presentAlert("Can't discover lure data with Lure service ID !")
            print("Can't discover lure data with Lure service ID !")
            delegate!.connectionStatus(false)
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
            print("\nProgramUI charateristic.UUID : \(thisCharacteristic.UUID)")
            // check for data characteristic
            if thisCharacteristic.UUID == self.LureCharPlayDefault {
                // Enable Sensor Notification
                print("\nProgramUI INFO : Reading Value from characteristic : \(LureCharPlayDefault) ")
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
                isCharHere = true
                
            }
            if thisCharacteristic.UUID == self.LureCharReadBatary {
                // Enable Sensor Notification
                print("\nProgramUI INFO : Reading Value from characteristic : \(LureCharReadBatary) ")
                self.sensorTagPeripheral.readValueForCharacteristic(thisCharacteristic)
                isCharHere = true
                
            }
            
            if thisCharacteristic.UUID == LureCharChangeSound {
                // Enable Sensor
                print("\nFind a change sound characteristic")
                print("\nProgramUI INFO : Reading Value from characteristic : \(LureCharChangeSound) ")
                self.changeSoundCharacteristic = thisCharacteristic
            }
        }
        if !isCharHere {
            self.presentAlert("Can't discover lure data with Characteristic ID !")
            print("Can't discover lure data with Characteristic ID !")
        }

    }
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        self.programText.text = "Connected"
        print("ProgramUI Connected !")
        //Variant 1
//        if characteristic.UUID == LureCharReadBatary {
//            // Convert NSData to array of signed 16 bit values
//            let dataBytes = characteristic.value
//            print("ProgramUI Connected : battery dataBytes \(dataBytes)")
//            let dataLength = dataBytes!.length
//            print("ProgramUI Connected : battery dataBytes lenght \(dataLength)")
//            var dataArray = [UInt8](count: dataLength, repeatedValue: 0)
//            dataBytes!.getBytes(&dataArray, length: dataLength * sizeof(UInt8))
//            print("ProgramUI Connected : battery dataArray.count : \(dataArray.count)")
////            let level = Int(dataArray[1])/128
//            let lvl = fromByteArray(dataArray, Int.self)
//            print("ProgramUI Connected : Battery lvl INT : \(lvl)")
//            let lvl2 = fromByteArray(dataArray, Double.self)
//            print("ProgramUI Connected : Battery lvl DOUBLE : \(lvl2)")
//            
//            // Display on the lvl label
//            self.delegate!.setMyBatteryValue(lvl)
//            print("ProgramUI Connected : Battery lvl : \(lvl)")
//        }
        
        //Variant 2
        if characteristic.UUID == LureCharReadBatary {
            // Convert NSData to array of signed 16 bit values
            let dataBytes = characteristic.value
            print("ProgramUI Connected : battery dataBytes \(dataBytes)")
            let dataLength = dataBytes!.length
            print("ProgramUI Connected : battery dataBytes lenght \(dataLength)")
            var dataArray = [Int16](count: dataLength, repeatedValue: 0)
            dataBytes!.getBytes(&dataArray, length: dataLength * sizeof(Int16))
            print("ProgramUI Connected : battery dataArray.count : \(dataArray.count)")
            let batteryLVL = Double(dataArray[0])/128
            print("ProgramUI Connected : Battery lvl DOUBLE : \(batteryLVL)")
            // Display on the temp label
            let text = NSString(format: "%.2f", batteryLVL)
            print("ProgramUI Connected : Battery lvl DOUBLE : \(text)")
            // Display on the lvl label
            self.delegate!.setMyBatteryValue(Int(batteryLVL))
        }
    }
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        self.programText.text = "Disconnected"
        central.scanForPeripheralsWithServices(nil, options: nil)
    }
    //MARK : On power button press we start to connect to device
    // We make a timer that gives 15 sec to find a divice in scan
    
    func fromByteArray<T>(value: [UInt8], _: T.Type) -> T {
        return value.withUnsafeBufferPointer {
            return UnsafePointer<T>($0.baseAddress).memory
        }
    }
    
    func powerConnectionLure(sender : UIButton!){
        _ = NSTimer.scheduledTimerWithTimeInterval(15, target:self, selector: Selector("stopSearchingDevice"), userInfo: nil, repeats: false)
        if self.sensorTagPeripheral != nil {
            self.centralManager.connectPeripheral(self.sensorTagPeripheral, options: nil)
            print("\nProgramUI centralManager.connectPeripheral\n")
        }
        
    }
    
    func stopSearchingDevice(){
        self.delegate?.stopProgres()
        self.delegate?.connectionStatus(false)
    }
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    func presentAlert(message : String){
        let alert = UIAlertController(title: "Alert", message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if sensorTagPeripheral != nil {
            print("\nProgramUI centralManager.connectPeripheral\n")
            self.centralManager.cancelPeripheralConnection(sensorTagPeripheral)
        }
    }

}
//Data source
extension ProgramUIViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 256.0
        }else{
            return 48.0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(programCell, forIndexPath: indexPath) as! ProgramCell
            
            self.delegate = cell
            
            cell.powerButton.addTarget(self, action: Selector("powerConnectionLure:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            let lureID = lureData!.LURE_ITEM_CODE
            let lureImgUrl = imgUrl + "\(lureID).png"
            let url = NSURL(string: lureImgUrl)
            
            cell.lureName.text = lureData?.LURE_NAME
            cell.lureStyle.text = lureData?.LURE_STYLE
            cell.lureType.text = lureData?.LURE_WATER_TYPE
            cell.progress.hidden = true
            
            self.getDataFromUrl(url!) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    cell.lureImage.image = UIImage(data: data!)
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("soundCell", forIndexPath: indexPath) 
            return cell
        }
    }
}
//Delegate
extension ProgramUIViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row > 0 {
            self.delegate?.stopProgres()
            var enableValue = NSInteger(indexPath.row)
            let enablyBytes = NSData(bytes: &enableValue, length: 1)
            if changeSoundCharacteristic != nil {
                self.sensorTagPeripheral.writeValue(enablyBytes, forCharacteristic: self.changeSoundCharacteristic!, type: CBCharacteristicWriteType.WithResponse)
                print("\nProgramUI writeValue : \(enableValue) : byte : \(enablyBytes) ")
                print("\nProgramUI row selected : \(indexPath.row)")
            }else{
                self.presentAlert("Can't connect to lure for sound changing !")
            }
        }
    }
}
