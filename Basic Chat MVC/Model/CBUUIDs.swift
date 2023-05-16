//
//  CBUUIDs.swift
//  Basic Chat MVC
//
//  Created by Trevor Beaton on 2/3/21.
//

import Foundation
import CoreBluetooth

struct CBUUIDs{

    static let kBLEService_UUID = "00001523-1212-EFDE-1523-785FEABCD123" //6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Rx = "00001524-1212-EFDE-1523-785FEABCD123" //SOT percent Char
    static let kBLE_Characteristic_uuid_Tx = "00001525-1212-EFDE-1523-785FEABCD123" //Goal Percent Char
    static let kBLE_Characteristic_uuid_State = "00001526-1212-EFDE-1523-785FEABCD123" //Drive State Char
    static let MaxCharacters = 20

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

}
