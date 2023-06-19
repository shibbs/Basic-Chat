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
    }
    
    //MARK: Outlets
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var status: UILabel!
    
    
    
    // MARK: - Functions
    
    func writeOutgoingValue(value: inout Int){
  //      let intValue = 0;
  //      let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
  //      if let utf8Data = data.data(using: .utf8),
  //          let intValue = Int(String(data: utf8Data, encoding: .utf8)!) {
  //              print("Converted integer value:", intValue)
  //      }else {
  //          return;
  //      }
        
        let data = Data(bytes: &value, count: 1)
        //change the "data" to valueString
      if let blePeripheral = BlePeripheral.connectedPeripheral {
            if let sot_Characteristic = BlePeripheral.sot_Char {
                blePeripheral.writeValue(data, for: sot_Characteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
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
