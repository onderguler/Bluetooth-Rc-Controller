//
//  SettingsViewController.swift
//  Bluetooth Rc Controller
//
//  Created by Onder Guler on 11.08.2024.
//

import UIKit
import CoreBluetooth

protocol SettingsViewControllerDelegate {
    var bluetoothManager: BluetoothManager! { get set }
    var connected: Bool! { get set }
}

class SettingsViewController: UIViewController {
    
    @IBOutlet private  weak var settingsTableView: UITableView!
    
    var bluetoothManager: BluetoothManager?
    
    var delegate: SettingsViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        bluetoothManager = BluetoothManager()
        bluetoothManager?.delegate = self
        bluetoothManager?.startScanning()
    }
    
    private func setupUI() {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        let nib = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        settingsTableView.register(nib, forCellReuseIdentifier: "SettingsTableViewCell")
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bluetoothManager?.discoveredPeripherals.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as? SettingsTableViewCell else { return UITableViewCell() }
        if let peripherals = bluetoothManager?.discoveredPeripherals, peripherals.count > indexPath.row {
            cell.configureUI(title:  peripherals[indexPath.row].name ?? "Unknown Device")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.bluetoothManager?.stopScanning()
        let selectedPeripheral = (bluetoothManager?.discoveredPeripherals[indexPath.row])!
        bluetoothManager?.centralManager!.connect(selectedPeripheral, options: nil)
        connected = true
        self.dismiss(animated: true) {
            self.delegate.bluetoothManager = self.bluetoothManager
            
        }
    }
}

extension SettingsViewController: BluetoothManagerDelegate {
    var connected: Bool! {
        get {
            return delegate.connected
        }
        set {
            delegate.connected = newValue
        }
    }
    func didUpdate(state: CBManagerState) {
        settingsTableView.reloadData()
    }
}
