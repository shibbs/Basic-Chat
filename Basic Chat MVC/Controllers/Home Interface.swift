//
//  Home Interface.swift
//  Tynt Demo
//
//  Created by Arjun on 6/11/23.
//

import UIKit
import SwiftUI
import CoreBluetooth

class Home_Interface: UIViewController {
    
    
    //MARK: Outlets/Variables
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var sensorData: UIButton!
    @IBOutlet weak var pairing: UIButton!
    @IBOutlet weak var tintValue: UILabel!
    @IBOutlet weak var tintProgress: UIProgressView!
    
    private var goalTintLevel: Int!
    private var tintProgressLength: Int!
    var currentTintLevel = 0
    
    var driveState: String! = ""
    var autoTintChar: String! = ""
    var temp: Float!
    var humidity: Float!
    var intLight: Float!
    var extLight: Float!
    var opticTrans: Float!
    var accelChar: String! = ""
    
    
    //MARK: - ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        slider.transform = CGAffineTransform(rotationAngle: CGFloat.pi / -2)
        
        slider.isEnabled = true
        
        update()
        
        sensorData.setTitle("", for: .normal)
        pairing.setTitle("", for: .normal)
        
        tintProgress.progress = 0
        tintProgress.isHidden = true
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.parseSOTPerc(notification:)), name: NSNotification.Name(rawValue: "NotifySOTP"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseDrvSt(notification:)), name: NSNotification.Name(rawValue: "NotifyDrvSt"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseATSChar(notification:)), name: NSNotification.Name(rawValue: "NotifyATS"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseTempChar(notification:)), name: NSNotification.Name(rawValue: "NotifyTemp"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseHumidityChar(notification:)), name: NSNotification.Name(rawValue: "NotifyHumidity"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseAmbLightChar(notification:)), name: NSNotification.Name(rawValue: "NotifyAL"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseAccelChar(notification:)), name: NSNotification.Name(rawValue: "NotifyAccel"), object: nil)
        
    }
    
    
    // MARK: - Functions
    
    func writeOutgoingValue(value: inout Int) {
        let data = Data(bytes: &value, count: 1)
        //change the "data" to valueString
        if let blePeripheral = BlePeripheral.connectedPeripheral {
            if let goalTintChar = BlePeripheral.goalTintChar {
                blePeripheral.writeValue(data, for: goalTintChar, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func update() {
        
        print(String(currentTintLevel) + " from update")
        
        if goalTintLevel == nil {
            
            statusText.text = "Idle"
//            slider.isEnabled = true
            slider.value = Float(currentTintLevel)
            tintValue.text = String(Int(round(slider.value))) + "% Tint"
            
        }
        else {
            
            tintProgress.progress = ( 1 - ((Float(abs(goalTintLevel - currentTintLevel)) / Float(tintProgressLength!))))

            if(driveState == "02") {
                statusText.text = "Bleaching: " + String(currentTintLevel) + "% Tint"
                tintProgress.isHidden = false
            }
            else if(driveState == "01") {
                statusText.text = "Tinting: " + String(currentTintLevel) + "% Tint"
                tintProgress.isHidden = false
            }
            else if(driveState == "00") {
                statusText.text = "Idle"
                slider.value = Float(currentTintLevel)
                tintValue.text = String(currentTintLevel) + "% Tint"
                tintProgress.progress = 0
                tintProgress.isHidden = true
            }
        }
        
    }
    
    @IBAction func writeValueToInterface(_ sender: UISlider) {
        tintValue.text = String(Int(round(slider.value))) + "% Tint"
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
    
    //MARK: - Parse Functions
    
    @objc func parseSOTPerc(notification: Notification) -> Void{
        
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print(text)
        
        let cur = Int(text, radix: 16)!
        currentTintLevel = cur
        
        update()
        
    }
    
    @objc func parseDrvSt(notification: Notification) -> Void {
        
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        driveState = text
        
        update()
    }
    
    @objc func parseATSChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print(text + ": ATSChar from parse method")
        
        autoTintChar = text
    }
    
    @objc func parseTempChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print(text + ": temp from parse method 1")
        
        let t = Int(text, radix: 16)!
        let value = Float(t)
        temp = value / 10
    }
    
    @objc func parseHumidityChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print(text + ": humidity from parse method")
        
        let t = Int(text, radix: 16)!
        let value = Float(t)
        humidity = value
    }
    
    @objc func parseAmbLightChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print(text + ": amblight from parse method 1")
        
        separateAmbLightChar(rawChar: text)
    }
    
    @objc func parseAccelChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print(text + ": accel from parse method")
        
        accelChar = text
    }
    
        @IBAction func valueOut(_ sender: Any) {
        
        var val = Int(round(slider.value))
        let cur = Int(currentTintLevel)
        
        if slider.value != Float(currentTintLevel) {
            
            tintProgress.progress = 0
            tintProgress.isHidden = false
            goalTintLevel = val
            tintProgressLength = abs(goalTintLevel - cur)
            
            statusText.text = "Working..."
            
            writeOutgoingValue(value: &val)
        }
        
    }
    
    
    // MARK: - Navigation
     
    @IBAction func returnToHome(segue: UIStoryboardSegue) {}
    
    @IBAction func goToPairing(_ sender: Any) {
        performSegue(withIdentifier: "unwindToPairing", sender: nil)
    }
    
    
    @IBAction func goToData(_ sender: Any) {
        performSegue(withIdentifier: "homeToData", sender: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         
        if segue.identifier == "unwindToPairing" {
            let destVC = segue.destination as? ViewController
            destVC?.homeButton.isHidden = false
        }
        else if segue.identifier == "homeToData" {
            let destVC = segue.destination as? Data_Interface
            destVC?.autoTintChar = autoTintChar
            destVC?.temp = temp
            destVC?.humidity = humidity
            destVC?.intLight = intLight
            destVC?.extLight = extLight
            destVC?.opticTrans = opticTrans
            destVC?.coulombCt = Float(currentTintLevel)
            destVC?.accelChar = accelChar
            
        }
    }
}
