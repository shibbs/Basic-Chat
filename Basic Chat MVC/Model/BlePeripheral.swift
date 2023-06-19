//
//  BlePeripheral.swift
//  Basic Chat MVC
//
//  Created by Trevor Beaton on 2/14/21.
//

import Foundation
import CoreBluetooth

class BlePeripheral {
 static var connectedPeripheral: CBPeripheral?
    //this is the Tynt Control Service
 static var tynt_control_Service: CBService?
 static var sot_Char: CBCharacteristic?
 static var goal_percent_Characteristic: CBCharacteristic?
 static var drv_state_Characteristic: CBCharacteristic?
//This is the tynt Sensor Srrvice
 static var tynt_sensor_Service: CBService?
 static var temp_sensor_Characteristic: CBCharacteristic?
 static var humidity_sensor_Characteristic: CBCharacteristic?
 static var light_sensor_Characteristic: CBCharacteristic?
 static var accel_sensor_Characteristic: CBCharacteristic?
}
