//
//  CBUUIDs.swift
//  Basic Chat MVC
//
//  Created by Trevor Beaton on 2/3/21.
//

import Foundation
import CoreBluetooth

struct CBUUIDs{

    //Tynt Contorl service UUID defines
    static let kTyntControlService_UUID = "00001523-1212-EFDE-1523-785FEABCD123" //6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Goal_Perc = "00001524-1212-EFDE-1523-785FEABCD123" //Goal percent Char
    static let kBLE_Characteristic_uuid_SOT_Perc = "00001525-1212-EFDE-1523-785FEABCD123" //SOT Percent Char
    static let kBLE_Characteristic_uuid_Drv_State = "00001526-1212-EFDE-1523-785FEABCD123" //Drive State Char
    static let MaxCharacters = 20

    static let TyntControlService_UUID = CBUUID(string: kTyntControlService_UUID)
    static let BLE_Characteristic_uuid_SOT_Perc = CBUUID(string: kBLE_Characteristic_uuid_SOT_Perc)//(Property = Write without response)
    static let BLE_Characteristic_uuid_Goal_Perc = CBUUID(string: kBLE_Characteristic_uuid_Goal_Perc)// (Property = Read/Notify)
    static let BLE_Characteristic_uuid_Drv_Perc = CBUUID(string: kBLE_Characteristic_uuid_Goal_Perc)// (Property = Read/Notify)
    
    //Sensor service UUID defines
    
    static let kTyntSensorService_UUID = "00001623-1212-EFDE-1523-785FEABCD123" //6e400001-b5a3-f393-e0a9-e50e24dcca9e"
//    static let kBLE_Characteristic_uuid_Goal_Perc = "00001624-1212-EFDE-1523-785FEABCD123" //Goal percent Char
//    static let kBLE_Characteristic_uuid_SOT_Perc = "00001625-1212-EFDE-1523-785FEABCD123" //SOT Percent Char
//    static let kBLE_Characteristic_uuid_Drv_State = "00001626-1212-EFDE-1523-785FEABCD123" //Drive State Char
//    static let MaxCharacters = 20
//
//    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
//    static let BLE_Characteristic_uuid_SOT_Perc = CBUUID(string: kBLE_Characteristic_uuid_SOT_Perc)//(Property = Write without response)
//    static let BLE_Characteristic_uuid_Goal_Perc = CBUUID(string: kBLE_Characteristic_uuid_Goal_Perc)// (Property = Read/Notify)
//    static let BLE_Characteristic_uuid_Drv_Perc = CBUUID(string: kBLE_Characteristic_uuid_Goal_Perc)// (Property = Read/Notify)

}
