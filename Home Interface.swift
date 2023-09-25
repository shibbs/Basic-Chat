//
//  Prime Interface.swift
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
    @IBOutlet weak var settings: UIButton!
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
        
        settings.setTitle("", for: .normal)
        
        tintProgress.progress = 0
        tintProgress.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showReceivedValue(notification:)), name: NSNotification.Name(rawValue: "Notify"), object: nil)
        
    }
    
    
    // MARK: - Functions
    
    func writeOutgoingValue(value: inout Int) {
        let data = Data(bytes: &value, count: 1)
        //change the "data" to valueString
        if let blePeripheral = BlePeripheral.connectedPeripheral {
            if let txCharacteristic = BlePeripheral.connectedTXChar {
                blePeripheral.writeValue(data, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func writeStatus(value: Int) {
        
//        print(String(currTintLevel) + " :currTintLevel from wS")
//        if currTintLevel == 0 {
//
//            statusText.text = "Please Pair a Tynt Device"
//            tintValue.text = String(Int(round(slider.value))) + "% Tint"
//            slider.isEnabled = false
//        }
        
        print(value)
        
        if goalTintLevel == nil {
            
            statusText.text = "Idle"
            slider.isEnabled = true
            slider.value = Float(value)
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
    
    func writeStatus() {
        
//        print(String(currTintLevel) + " :currTintLevel from wS")
        if currTintLevel == 0 {
            
            statusText.text = "Please Pair a Tynt Device"
            tintValue.text = String(Int(round(slider.value))) + "% Tint"
            slider.isEnabled = false
        }
        
//        else if goalTintLevel == nil {
//
//            statusText.text = "Idle"
//            slider.isEnabled = true
//            slider.value = Float(value)
//            tintValue.text = String(Int(round(slider.value))) + "% Tint"
//
//        }
//        else {
//
//            tintProgress.progress = ( 1 - ((Float(abs(goalTintLevel - currTintLevel)) / Float(tintProgressLength!))))
//
//            if(currTintLevel > goalTintLevel) {
//                statusText.text = "Bleaching: " + String(currTintLevel) + "% Tint"
//            }
//            else if(currTintLevel < goalTintLevel) {
//                statusText.text = "Tinting: " + String(currTintLevel) + "% Tint"
//            }
//        }
        
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
    
    
    @objc func showReceivedValue(notification: Notification) -> Void{
        
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        print(text)
        
        let cur = Int(text, radix: 16)!
        currTintLevel = cur
        
        print(String(currTintLevel) + " :currTintLevel from sRV")
        
        writeStatus(value: currTintLevel)
        
//        testingMethod()
        
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    // }
}
