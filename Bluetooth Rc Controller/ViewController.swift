//
//  ViewController.swift
//  Bluetooth Rc Controller
//
//  Created by Onder Guler on 11.08.2024.
//

import UIKit

class ViewController: UIViewController, SettingsViewControllerDelegate {
    var connected: Bool! {
        didSet {
            connectionStatusView.backgroundColor = connected ? .green : .red
        }
    }
    
    var bluetoothManager: BluetoothManager!
    
    @IBOutlet weak var connectionStatusView: UIView!
    @IBOutlet weak var turretSwitch: UISwitch!
    @IBOutlet weak var fireSwitch: UISwitch!
    @IBOutlet weak var laserSwitch: UISwitch!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backWardButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI() {
        connectionStatusView.layer.cornerRadius = connectionStatusView.frame.height / 2
        connectionStatusView.clipsToBounds = true
        speedSlider.isContinuous = false
        
        let forwardButtonGesture = UILongPressGestureRecognizer(target: self, action: #selector(forwardButtonTapped(_:)))
        forwardButtonGesture.minimumPressDuration =  0.05
        forwardButton.addGestureRecognizer(forwardButtonGesture)
        
        let backWardButtonGesture = UILongPressGestureRecognizer(target: self, action: #selector(backWardButtonTapped(_:)))
        backWardButtonGesture.minimumPressDuration = 0.05
        backWardButton.addGestureRecognizer(backWardButtonGesture)
        
        let leftButtonGesture = UILongPressGestureRecognizer(target: self, action: #selector(leftButtonTapped(_:)))
        leftButtonGesture.minimumPressDuration =  0.05
        leftButton.addGestureRecognizer(leftButtonGesture)
        
        let rightButtonGesture = UILongPressGestureRecognizer(target: self, action: #selector(rightButtonTapped(_:)))
        rightButtonGesture.minimumPressDuration =  0.05
        rightButton.addGestureRecognizer(rightButtonGesture)
    }
    
    @objc func forwardButtonTapped(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            sendValueToBluetooth(character: "F")

        } else if gestureRecognizer.state == .ended {
            sendValueToBluetooth(character: "S")
        }
        
    }
    
    @objc func backWardButtonTapped(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            sendValueToBluetooth(character: "B")

        } else if gestureRecognizer.state == .ended {
            sendValueToBluetooth(character: "S")

        }
    }
    @objc func leftButtonTapped(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            sendValueToBluetooth(character: "L")

        } else if gestureRecognizer.state == .ended {
            sendValueToBluetooth(character: "S")

        }
    }
    
    @objc func rightButtonTapped(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            sendValueToBluetooth(character: "R")

        } else if gestureRecognizer.state == .ended {
            sendValueToBluetooth(character: "S")

        }
    }

    @IBAction func turretButtonTapped(_ sender: Any) {
        if turretSwitch.isOn {
            sendValueToBluetooth(character: "W")
        } else {
            sendValueToBluetooth(character: "w")
        }
        
    }
    
    @IBAction func fireButtonTapped(_ sender: Any) {
        if fireSwitch.isOn {
            sendValueToBluetooth(character: "U")
        } else {
            sendValueToBluetooth(character: "u")
        }
    }
    
    @IBAction func laserButtonTapped(_ sender: Any) {
        if laserSwitch.isOn {
            sendValueToBluetooth(character: "X")
        } else {
            sendValueToBluetooth(character: "x")
        }
    }
    
    @IBAction func speedSliderChanged(_ sender: Any) {
        switch speedSlider.value {
        case 10:
            sendValueToBluetooth(character: "q")
        default:
            
            if let char = "\(Int(speedSlider.value))".first {
                sendValueToBluetooth(character: char)
            }
        }
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)

    }
    
    private func sendValueToBluetooth(character: Character) {
        
        if let data = String(character).data(using: .utf8) {
            bluetoothManager?.writeDataToPeripheral(data: data)
        } else {
            print("Failed to convert character to data")
        }
    }

}

