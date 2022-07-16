//
//  ListCell.swift
//  LaunchesX
//
//  Created by Denys Shkola on 12.07.2022.
//

import UIKit

class ListCell: UITableViewCell {

    @IBOutlet weak var patchImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        
        backView.layer.cornerRadius = 15.0
    }
    
}
