//
//  SummaryTableViewCell.swift
//  PoForecast
//
//  Created by Paul Lee on 2022/08/29.
//

import UIKit

class SummaryTableViewCell: UITableViewCell {
    
    static let identifier = "SummaryTableViewCell"
    
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var minMaxLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        
        statusLabel.textColor = .white
        minMaxLabel.textColor = statusLabel.textColor
        currentTemperatureLabel.textColor = statusLabel.textColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
