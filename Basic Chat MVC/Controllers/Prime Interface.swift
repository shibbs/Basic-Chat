//
//  Prime Interface.swift
//  Basic Chat MVC
//
//  Created by Arjun on 6/11/23.
//

import UIKit
import SwiftUI
import CoreBluetooth

class Prime_Interface: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        slider.transform = CGAffineTransform(rotationAngle: CGFloat.pi / -2)
        tintValue.text = "50% Tint"
    }
    
    //MARK: Outlets
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var settings: UIButton!
    @IBOutlet weak var tintValue: UILabel!
    
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
    
    
    @IBAction func writeValue(_ sender: UISlider) {
        var val = Int(round(slider.value))
        writeOutgoingValue(value: &val)
        
        tintValue.text = String(val) + "% Tint"
    }
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
