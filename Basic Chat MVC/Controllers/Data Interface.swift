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
    @IBOutlet weak var alertslabel: UILabel!
    @IBOutlet weak var coulombCountLabel: UILabel!
    @IBOutlet weak var autoTintSwitch: UISwitch!
    
    var autoTintChar: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseATSChar(notification:)), name: NSNotification.Name(rawValue: "NotifyATS"), object: nil)

        homeButton.setTitle("", for: .normal)
        
        update()
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
    
    @objc func parseATSChar(notification: Notification) -> Void {
        var text = String(describing: notification.object)
        text = text.replacingOccurrences(of: "Optional(<", with: "")
        text = text.replacingOccurrences(of: ">)", with: "")
        
        autoTintChar = text
    }
    
    func update() {
        
        if autoTintChar == "00" { autoTintSwitch.isOn = false
        }
        else if autoTintChar == "01" { autoTintSwitch.isOn = true }
    }
    
    // MARK: - IB Action Funcs
    
    @IBAction func autoTintStatus(_ sender: Any) {
        
        var val: Int!
        
        if autoTintSwitch.isOn { val = 1 }
        else if !autoTintSwitch.isOn { val = 0 }
        
        writeAutoTintState(value: &val)
    }
    
    
    // MARK: - Navigation

     @IBAction func backToHome(_ sender: Any) {
         performSegue(withIdentifier: "unwindToHome", sender: nil)
     }
     
    
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
    
}
