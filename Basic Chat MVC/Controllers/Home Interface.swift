//
//  Home Interface.swift
//  Tynt Demo
//
//  Created by Arjun on 6/11/23.
//

import UIKit
import SwiftUI
import CoreBluetooth
import Darwin

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
    var currTintLevel = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        slider.transform = CGAffineTransform(rotationAngle: CGFloat.pi / -2)
        
        slider.isEnabled = true
        
        writeStatus()
        
        sensorData.setTitle("", for: .normal)
        pairing.setTitle("", for: .normal)
        
        tintProgress.progress = 0
        tintProgress.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseSOTPerc(notification:)), name: NSNotification.Name(rawValue: "NotifySOTP"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseDrvSt(notification:)), name: NSNotification.Name(rawValue: "NotifyDrvSt"), object: nil)
        
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
    
    func writeStatus() {
        
        print(String(currTintLevel) + " from writeStatus")
        
        if goalTintLevel == nil {
            
            statusText.text = "Idle"
            slider.isEnabled = true
            slider.value = Float(currTintLevel)
            tintValue.text = String(Int(round(slider.value))) + "% Tint"
            
        }
        else {
            
            tintProgress.progress = ( 1 - ((Float(abs(goalTintLevel - currTintLevel)) / Float(tintProgressLength!))))
            
            if(currTintLevel > goalTintLevel) {
                statusText.text = "Bleaching: " + String(currTintLevel) + "% Tint"
            }
            else if(currTintLevel < goalTintLevel) {
                statusText.text = "Tinting: " + String(currTintLevel) + "% Tint"
            }
        }
        
        endProcess()
    }
    
    func testingMethod() {
        print(currTintLevel)
        print(" testingMethodOutput")
    }
    
    
    @IBAction func writeValueToInterface(_ sender: UISlider) {
        tintValue.text = String(Int(round(slider.value))) + "% Tint"
    }
    
//    @IBAction func writeOutValue(_ sender: UISlider) {
//
//        var val = Int(round(slider.value))
//        writeOutgoingValue(value: &val)
//        goalTintLevel = val
//        slider.isEnabled = false
//
//        tintProgress.isHidden = false
//        tintProgress.progress = 0
//        tintProgressLength = abs(goalTintLevel - currentTintLevel)
//    }
    
    
    @objc func parseSOTPerc(notification: Notification) -> Void{
        
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print(text)
        
        let cur = Int(text, radix: 16)!
        currTintLevel = cur
        
        print(String(currTintLevel) + " :currTintLevel from sRV")
        
        writeStatus()
        
//        testingMethod()
        
    }
    
    @objc func parseDrvSt(notification: Notification) -> Void {
        
        var text = String(describing: notification.object)
        print(text)
    }
    
        @IBAction func valueOut(_ sender: Any) {
//        testingMethod()
        
        var val = Int(round(slider.value))
        let cur = Int(currTintLevel)
        
        if slider.value != Float(currTintLevel) {
            
            slider.isEnabled = false
            tintProgress.progress = 0
            tintProgress.isHidden = false
            goalTintLevel = val
            tintProgressLength = abs(goalTintLevel - cur)
            
            statusText.text = "Working..."
            
            writeOutgoingValue(value: &val)
        }
        
    }
    

    
    func endProcess() {

        if(goalTintLevel != nil) {
            if(abs(goalTintLevel - currTintLevel) <= 1) {
                currTintLevel = goalTintLevel
                statusText.text = "Idle"
                tintProgress.progress = 0
                tintProgress.isHidden = true
                slider.isEnabled = true
            }
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
    }
}
