//
//  Data_Interface.swift
//  Tynt Demo
//
//  Created by Arjun Dalwadi on 6/25/23.
//

import UIKit
import CoreBluetooth

class Data_Interface: UIViewController {
    
    // MARK: - Outlets/Variables
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var intLightLabel: UILabel!
    @IBOutlet weak var extLightLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var opticTransLabel: UILabel!
    @IBOutlet weak var alertsLabel: UILabel!
    @IBOutlet weak var coulombCountLabel: UILabel!
    @IBOutlet weak var driveStateLabel: UILabel!
    @IBOutlet weak var autoTintSwitch: UISwitch! //not used anywhere other than parse function right now
    
    var autoTintChar: String!
    var accelChar: String!
    var ambLightChar: String!
    
    var temp: Float!
    var humidity: Float!
    var intLight: Float!
    var extLight: Float!
    var opticTrans: Float!
    var coulombCt: Float!
    var driveState: String!
    
    
    //MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeButton.setTitle("", for: .normal)
        
        tempLabel.text = "\u{2014}" + "\u{00B0}" + " Celsius"
        humidityLabel.text = "\u{2014}%"
        intLightLabel.text = "\u{2014} Lumens"
        extLightLabel.text = "\u{2014} Lumens"
        opticTransLabel.text = "\u{2014}%"
        alertsLabel.text = "\u{2014}"
        coulombCountLabel.text = "\u{2014}%"
        driveStateLabel.text = "\u{2014}"
        
        update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    // MARK: - Functions
    
    func writeAutoTintState(value: inout Int) {
        let data = Data(bytes: &value, count: 1)
        //change the "data" to valueString
        if let blePeripheral = BlePeripheral.connectedPeripheral {
            if let autoTintChar = BlePeripheral.autoTintChar {
                blePeripheral.writeValue(data, for: autoTintChar, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func separateAmbLightChar(rawChar: String) {
        
        let bytes = rawChar.components(separatedBy: " ")
        
        let intLightBytes = bytes[0]
        let extLightBytes = bytes[1]
        let extTintBytes = bytes[2]
        
        let i = Float(Int(intLightBytes, radix: 16)!)
        intLight = i / 10
        
        let e = Float(Int(extLightBytes, radix: 16)!)
        extLight = e / 10
        
        let et = Float(Int(extTintBytes, radix: 16)!)
        
        let x = (et / e) * 1000
        opticTrans = (roundf(x) / 10.0)
        
    }
    
    func update() {
        
        if autoTintChar == "00" { autoTintSwitch.isOn = false }
        else if autoTintChar == "01" { autoTintSwitch.isOn = true }
        
        tempLabel.text = String(temp) + "\u{00B0}" + " C"
        humidityLabel.text = String(Int(humidity)) + "%"
        intLightLabel.text = String(intLight) + " Lumens"
        extLightLabel.text = String(extLight) + " Lumens"
        opticTransLabel.text = String(opticTrans) + "%"
        coulombCountLabel.text = String(Int(coulombCt)) + "%"
        
        if accelChar == "00" { alertsLabel.text = "None" }
        else if accelChar == "01" { alertsLabel.text = "Bang/Smash Detected" }
        else if accelChar == "02" { alertsLabel.text = "Rain Detected" }
        
        if driveState == "00" { driveStateLabel.text = "Idle" }
        else if driveState == "01" { driveStateLabel.text = "Tinting" }
        else if driveState == "02" { driveStateLabel.text = "Bleaching" }
        
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseATSChar(notification:)), name: NSNotification.Name(rawValue: "NotifyATS"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.parseTempChar(notification:)), name: NSNotification.Name(rawValue: "NotifyTemp"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseHumidityChar(notification:)), name: NSNotification.Name(rawValue: "NotifyHumidity"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.parseAmbLightChar(notification:)), name: NSNotification.Name(rawValue: "NotifyAL"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.parseCoulombCtChar(notification:)), name: NSNotification.Name(rawValue: "NotifySOTP"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.parseAccelChar(notification:)), name: NSNotification.Name(rawValue: "NotifyAccel"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseDrvSt(notification:)), name: NSNotification.Name(rawValue: "NotifyDrvSt"), object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("NotifyATS"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("NotifyTemp"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("NotifyHumidity"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("NotifyAL"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("NotifySOTP"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("NotifyAccel"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("NotifyDrvSt"), object: nil)
    }
    
    
    //MARK: - Parse Functions
    
    @objc func parseATSChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print("auto tint state was updated")
        
        autoTintChar = text
        
        update()
        
    }
    
    @objc func parseTempChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print(text + ": temp from parse method")
        
        //MARK: - Handle Signed Bits Accordingly Below
        
        let t = Int(text, radix: 16)!
        let value = Float(t)
        temp = value / 10
        
        update()
    }
    
    @objc func parseHumidityChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print(text + ": humidity from parse method")
        
        let t = Int(text, radix: 16)!
        let value = Float(t)
        humidity = value
        
        update()
    }
    
    @objc func parseAmbLightChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print(text + ": amblight from parse method")
        
        separateAmbLightChar(rawChar: text)
        
        update()
    }
    
    @objc func parseCoulombCtChar(notification: Notification) -> Void{
        
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print(text)
        
        let t = Int(text, radix: 16)!
        let v = Float(t)
        coulombCt = v
        
        update()
    }
    
    @objc func parseAccelChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print(text + ": accel from parse method")
        
        accelChar = text
        
        update()
    }
    
    @objc func parseDrvSt(notification: Notification) -> Void {
        
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        driveState = text
        
        update()
    }
    
    
    // MARK: - IB Action Functionss
    
    @IBAction func autoTintStatus(_ sender: Any) {
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) {_ in
            switch BlePeripheral.connectedPeripheral!.state {
            case .disconnected:
                self.autoTintSwitch.isEnabled = false
                self.performSegue(withIdentifier: "unwindToHomeDisconnection", sender: nil)
            case .disconnecting:
                self.autoTintSwitch.isEnabled = false
                self.performSegue(withIdentifier: "unwindToHomeDisconnection", sender: nil)
            case .connecting:
                print("Still connecting")
            case.connected:
                var val: Int!
                
                if self.autoTintSwitch.isOn { val = 1 }
                else if !self.autoTintSwitch.isOn { val = 0 }
                
                self.writeAutoTintState(value: &val)
                
            @unknown default:
                print("Unknown error")
            }
        }
    }
    
    
    // MARK: - Navigation
    
    @IBAction func backToHome(_ sender: Any) {
        performSegue(withIdentifier: "unwindToHome", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unwindToHomeDisconnection" {
            let destVC = segue.destination as? Home_Interface
            
            destVC?.deviceDisconnected = true
            
        }
        
    }
    
}
