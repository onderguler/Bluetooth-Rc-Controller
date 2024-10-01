//
//  SettingsTableViewCell.swift
//  Bluetooth Rc Controller
//
//  Created by Onder Guler on 11.08.2024.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureUI(title: String) {
        titleLabel.text = title
    }
}
