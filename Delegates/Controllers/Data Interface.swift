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
    
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var intLightLabel: UILabel!
    @IBOutlet weak var extLightLabel: UILabel!
    @IBOutlet weak var extTintedLightLabel: UILabel!
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
    var extTintedLight: Float!
    var opticTrans: Float!
    var coulombCt: Int!
    var driveState: String!
    
    var timer = Timer()
    
    
    //MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeButton.setTitle("", for: .normal)
        
        tempLabel.text = "\u{2014}" + "\u{00B0}" + " Celsius"
        humidityLabel.text = "\u{2014}%"
        intLightLabel.text = "\u{2014} Lumens"
        extLightLabel.text = "\u{2014} Lumens"
        extTintedLightLabel.text = "\u{2014} Lumens"
        opticTransLabel.text = "\u{2014}%"
        alertsLabel.text = "\u{2014}"
        coulombCountLabel.text = "\u{2014}%"
        driveStateLabel.text = "\u{2014}"
        
        update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addObservers()
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
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
                self.update()
                
            @unknown default:
                print("Unknown error")
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
        timer.invalidate()
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
        intLight = i / 100
        
        let e = Float(Int(extLightBytes, radix: 16)!)
        extLight = e / 100
        
        let et = Float(Int(extTintBytes, radix: 16)!)
        extTintedLight = et / 100
        
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
        extTintedLightLabel.text = String(extTintedLight) + " Lumens"
        opticTransLabel.text = String(opticTrans) + "%"
        coulombCountLabel.text = String(Int(coulombCt)) + "%"
        
        if accelChar == "00" { alertsLabel.text = "None" }
        else if accelChar == "01" { alertsLabel.text = "Bang/Smash Detected" }
        else if accelChar == "02" { alertsLabel.text = "Rain Detected" }
        
        if driveState == "00" { driveStateLabel.text = "Idle" }
        else if driveState == "01" { driveStateLabel.text = "Tinting" }
        else if driveState == "02" { driveStateLabel.text = "Bleaching" }
        else if driveState == "03" { driveStateLabel.text = "Working" }
        
        print("updated (data interface)")
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
        
        autoTintChar = text
        
        print("auto tint state was updated")
        
    }
    
    @objc func parseTempChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        let chars = Array(text)
        
        let b1 = String(chars[0]) + String(chars[1])
        let b2 = String(chars[2]) + String(chars[3])
        
        let a = Int(b1, radix: 16)!
        let b = Int(b2, radix: 16)!
        
        let v = Float(a + (256*b))
        temp = v / 10
        
        print(String(temp) + " : tempChar from sensor data")
        
        
        //MARK: - Handle Signed Bits Accordingly
        
    }
    
    @objc func parseHumidityChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        let t = Int(text, radix: 16)!
        let value = Float(t)
        humidity = value
        
        print(text + " : humidityChar from sensor data")
        
    }
    
    @objc func parseAmbLightChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        separateAmbLightChar(rawChar: text)
        
        print(text + " : ambLightChar from sensor data")
        
    }
    
    @objc func parseCoulombCtChar(notification: Notification) -> Void{
        
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        let t = Int(text, radix: 16)!
        coulombCt = t
        
        print(text + " : coulombCtChar from sensor data")
        
    }
    
    @objc func parseAccelChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        accelChar = text
        
        print(text + " : accelChar from sensor data")
        
    }
    
    @objc func parseDrvSt(notification: Notification) -> Void {
        
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        driveState = text
        
        print(text + " : drvStChar from sensor data")
        
    }
    
    
    // MARK: - IB Action Functionss
    
    @IBAction func autoTintStatus(_ sender: Any) {
        
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
            
            if self.autoTintSwitch.isOn { val = 1 ; autoTintChar = "01" }
            else if !self.autoTintSwitch.isOn { val = 0 ; autoTintChar = "00"}
            
            self.writeAutoTintState(value: &val)
            
        @unknown default:
            print("Unknown error")
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
        else if segue.identifier == "unwindToHome" {
            let destVC = segue.destination as? Home_Interface
            
            destVC?.currentTintLevel = coulombCt
            destVC?.autoTintChar = autoTintChar
            destVC?.update()
        }
        
    }
    
}
