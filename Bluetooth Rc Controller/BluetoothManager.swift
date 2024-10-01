//
//  BluetoothManager.swift
//  Bluetooth Rc Controller
//
//  Created by Onder Guler on 11.08.2024.
//

import Foundation
import CoreBluetooth

protocol BluetoothManagerDelegate {
    func didUpdate(state: CBManagerState)
    var connected: Bool! { get set}
}

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager?
    var discoveredPeripherals: [CBPeripheral] = []
    var peripheral: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?
    
    
    var delegate: BluetoothManagerDelegate!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Bluetooth cihazlarını taramak için kullanılan fonksiyon
    func startScanning() {
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScanning() {
        centralManager?.stopScan()
    }
    
    // Merkezi yöneticinin Bluetooth durumunu kontrol eden fonksiyon
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is ON. Scanning for devices...")
            startScanning()
        case .poweredOff:
            print("Bluetooth is OFF.")
        case .resetting:
            print("Bluetooth is resetting.")
        case .unauthorized:
            print("Bluetooth is unauthorized.")
        case .unsupported:
            print("Bluetooth is unsupported.")
        case .unknown:
            print("Bluetooth state is unknown.")
        @unknown default:
            fatalError()
        }
    }
    
    // Bulunan cihazları yakalayan fonksiyon
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append(peripheral)
            if delegate != nil {
                delegate.didUpdate(state: .poweredOn)
            }
            print("Discovered: \(peripheral.name ?? "Unknown") - RSSI: \(RSSI)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.peripheral?.delegate = self // Delegate ayarı yapılmalı
        self.peripheral?.discoverServices(nil)
        if delegate != nil {
            delegate.connected = true
        }
        print("Connected to \(peripheral.name ?? "Unknown Device")")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown Device")")
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        for characteristic in service.characteristics ?? [] {
            // Assuming this characteristic is writable
            if characteristic.properties.contains(.write) {
                writeCharacteristic = characteristic
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error discovering descriptors: \(error.localizedDescription)")
            return
        }
        
        for descriptor in characteristic.descriptors ?? [] {
            print("Discovered descriptor \(descriptor.uuid)")
        }
    }
    
    func writeDataToPeripheral(data: Data) {
        guard let peripheral = peripheral, let characteristic = writeCharacteristic else {
            print("Peripheral or characteristic not found")
            return
        }
        print("Peripheral name \(peripheral.name ?? "unknown"), Gönderilen karekter \(String(data: data, encoding: .utf8) ?? "unknown")")
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value: \(error.localizedDescription)")
            return
        }
        
        // Handle received data here
        if let value = characteristic.value {
            print("Received data: \(value)")
        }
    }
}
