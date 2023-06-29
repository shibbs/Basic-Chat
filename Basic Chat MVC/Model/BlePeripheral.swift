//
//  BlePeripheral.swift
//
//  Created by Arjun on 6/11/23.
//

import Foundation
import CoreBluetooth

class BlePeripheral {
 static var connectedPeripheral: CBPeripheral?
 static var connectedService: CBService?
 static var goalTintChar: CBCharacteristic?
 static var SOTChar: CBCharacteristic?
    static var DrvStChar: CBCharacteristic?
}
