
// associated with "Pairing Interface"

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    // Data
    private var centralManager: CBCentralManager!
    private var bluefruitPeripheral: CBPeripheral!
    private var goalTintChar: CBCharacteristic!
    private var SOTChar: CBCharacteristic!
    private var DrvStChar: CBCharacteristic!
    private var peripheralArray: [CBPeripheral] = []
    private var rssiArray = [NSNumber]()
    private var timer = Timer()
    var currentTintLevel: Int!
    let defaults = UserDefaults.standard

    // UI
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var peripheralFoundLabel: UILabel!
    @IBOutlet weak var scanningButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    @IBAction func scanningAction(_ sender: Any) {
    startScanning()
  }

    override func viewDidLoad() {
      super.viewDidLoad()
        
      homeButton.setTitle("", for: .normal)
      homeButton.isHidden = true

      self.tableView.delegate = self
      self.tableView.dataSource = self
      self.tableView.reloadData()
      // Manager
      centralManager = CBCentralManager(delegate: self, queue: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseSOTPerc(notification:)), name: NSNotification.Name(rawValue: "NotifySOTP"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
      //disconnectFromDevice()
      self.tableView.reloadData()
      //startScanning()
    }
    
    @IBAction func segueToHome(_ sender: Any) {
        performSegue(withIdentifier: "pairingToHome", sender: nil)
    }
    
    func connectToDevice() -> Void {
      centralManager?.connect(bluefruitPeripheral!, options: nil)
        let string = String(describing: bluefruitPeripheral.identifier)
        print("string: " + string)
        defaults.setValue(String(describing: bluefruitPeripheral.identifier), forKey: "LastConnectedUUID")
        print(bluefruitPeripheral.identifier)
  }

    func disconnectFromDevice() -> Void {
      if bluefruitPeripheral != nil {
        centralManager?.cancelPeripheralConnection(bluefruitPeripheral!)
      }
  }

    func removeArrayData() -> Void {
      centralManager.cancelPeripheralConnection(bluefruitPeripheral)
           rssiArray.removeAll()
           peripheralArray.removeAll()
       }

    func startScanning() -> Void {
        // Remove prior data
        peripheralArray.removeAll()
        rssiArray.removeAll()
        // Start Scanning
        print("Started startScanning");
        centralManager?.scanForPeripherals(withServices: []) //CBUUIDs.BLEService_UUID])
        scanningButton.setTitle("Scanning...", for: .normal)
        scanningButton.isEnabled = false
        
        if let lastUUID = defaults.value(forKey: "LastConnectedUUID") {
            for periph in peripheralArray {
                if String(describing: lastUUID) == String(describing: periph.identifier) {

                    BlePeripheral.connectedPeripheral = periph

                    connectToDevice()

                    self.performSegue(withIdentifier: "pairingToHome", sender: nil)
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 15, repeats: false) {_ in
            self.stopScanning()
        }
    }

    func scanForBLEDevices() -> Void {
      // Remove prior data
      peripheralArray.removeAll()
      rssiArray.removeAll()
      // Start Scanning
        print("Started ScanForBLEDevice");
      centralManager?.scanForPeripherals(withServices: [] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        scanningButton.setTitle("Scanning...", for: .normal)
        scanningButton.isEnabled = false

      Timer.scheduledTimer(withTimeInterval: 15, repeats: false) {_ in
          self.stopScanning()
      }
  }

    func stopTimer() -> Void {
      // Stops Timer
      self.timer.invalidate()
    }

    func stopScanning() -> Void {
        scanningButton.setTitle("Scan", for: .normal)
        scanningButton.isEnabled = true
        centralManager?.stopScan()
    }

    func delayedConnection() -> Void {

    BlePeripheral.connectedPeripheral = bluefruitPeripheral

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
      //Once connected, move to new view controller to manager incoming and outgoing data
      let storyboard = UIStoryboard(name: "Main", bundle: nil)

//        let detailViewController = storyboard.instantiateViewController(withIdentifier: "ConsoleViewController") as! ConsoleViewController
        
      self.performSegue(withIdentifier: "pairingToHome", sender: nil)

    })
  }
}

// MARK: - CBCentralManagerDelegate
// A protocol that provides updates for the discovery and management of peripheral devices.
extension ViewController: CBCentralManagerDelegate {

    // MARK: - Check
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

      switch central.state {
        case .poweredOff:
            print("Is Powered Off.")

            let alertVC = UIAlertController(title: "Bluetooth Required", message: "Check your Bluetooth Settings", preferredStyle: UIAlertController.Style.alert)

            let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            })

            alertVC.addAction(action)

            self.present(alertVC, animated: true, completion: nil)

        case .poweredOn:
            print("Is Powered On.")
            startScanning()
        case .unsupported:
            print("Is Unsupported.")
        case .unauthorized:
        print("Is Unauthorized.")
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        @unknown default:
          print("Error")
        }
    }

    // MARK: - Discover
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
      print("Function: \(#function),Line: \(#line)")

      bluefruitPeripheral = peripheral
      print("Peripheral found");
        let p_name = peripheral.name ?? ""; //get the name and cast to null if empty
      if peripheralArray.contains(peripheral) {
          print("Duplicate Found.")
      } else if(p_name.contains( "Tynt_Demo")){
        peripheralArray.append(peripheral)
        rssiArray.append(RSSI)
          peripheralFoundLabel.text = "Peripherals Found: \(peripheralArray.count)"

          bluefruitPeripheral.delegate = self

          print("Peripheral Discovered: \(peripheral)")

          self.tableView.reloadData()
      }

      
    }

    // MARK: - Connect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        stopScanning()
        bluefruitPeripheral.discoverServices([CBUUIDs.cService_UUID, CBUUIDs.sService_UUID])
    }
}

// MARK: - CBPeripheralDelegate
// A protocol that provides updates on the use of a peripheral’s services.
extension ViewController: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

      guard let services = peripheral.services else { return }
      for service in services {
        peripheral.discoverCharacteristics(nil, for: service)
      }
      BlePeripheral.connectedService = services[0]
    }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

    guard let characteristics = service.characteristics else {
        return
    }

    print("Found \(characteristics.count) characteristics.")

    for characteristic in characteristics {

      if characteristic.uuid.isEqual(CBUUIDs.cService_Characteristic_uuid_StateOfTint)  {

        SOTChar = characteristic

        BlePeripheral.SOTChar = SOTChar

        peripheral.setNotifyValue(true, for: SOTChar!)
        peripheral.readValue(for: characteristic)

        print("RX Characteristic: \(SOTChar.uuid)")
      }
        else if characteristic.uuid.isEqual(CBUUIDs.cService_Characteristic_uuid_DriveState) {
            
            DrvStChar = characteristic

            BlePeripheral.DrvStChar = DrvStChar

            peripheral.setNotifyValue(true, for: DrvStChar!)
            peripheral.readValue(for: characteristic)

            print("DrvStCharacteristic: \(DrvStChar.uuid)")
        }

      if characteristic.uuid.isEqual(CBUUIDs.cService_Characteristic_uuid_GoalTint){
        goalTintChar = characteristic
        BlePeripheral.goalTintChar = goalTintChar
        print("TX Characteristic: \(goalTintChar.uuid)")
      }
        
        
    }
    delayedConnection()
 }



  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor char: CBCharacteristic, error: Error?) {
      
      if char == SOTChar {

          NotificationCenter.default.post(name:NSNotification.Name(rawValue: "NotifySOTP"), object: char.value! as Data)
      }
      else if char == DrvStChar {

          NotificationCenter.default.post(name:NSNotification.Name(rawValue: "NotifyDrvSt"), object: char.value! as Data)
      }

  }

  func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        peripheral.readRSSI()
    }

  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
      guard error == nil else {
          print("Error discovering services: error")
          return
      }
    print("Function: \(#function),Line: \(#line)")
      print("Message sent")
  }


  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
      print("*******************************************************")
    print("Function: \(#function),Line: \(#line)")
      if (error != nil) {
          print("Error changing notification state:\(String(describing: error?.localizedDescription))")

      } else {
          print("Characteristic's value subscribed")
      }

      if (characteristic.isNotifying) {
          print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
      }
  }

}

// MARK: - UITableViewDataSource
// The methods adopted by the object you use to manage data and provide cells for a table view.
extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripheralArray.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

      let cell = tableView.dequeueReusableCell(withIdentifier: "BlueCell") as! TableViewCell

      let peripheralFound = self.peripheralArray[indexPath.row]

      let rssiFound = self.rssiArray[indexPath.row]

        if peripheralFound == nil {
            cell.peripheralLabel.text = "Unknown"
        }else {
            cell.peripheralLabel.text = peripheralFound.name
            cell.rssiLabel.text = "RSSI: \(rssiFound)"
        }
        return cell
    }


}


// MARK: - UITableViewDelegate
// Methods for managing selections, deleting and reordering cells and performing other actions in a table view.
extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

      bluefruitPeripheral = peripheralArray[indexPath.row]

        BlePeripheral.connectedPeripheral = bluefruitPeripheral

        connectToDevice()

    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToPairing(segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         
        if segue.identifier == "pairingToHome" {
            let destVC = segue.destination as? Home_Interface
            
            destVC?.currTintLevel = currentTintLevel
        }
    }
    
    @objc func parseSOTPerc(notification: Notification) -> Void{

        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")

        print(text)

        let cur = Int(text, radix: 16)!
        currentTintLevel = cur

    }
    
}
