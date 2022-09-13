//
//  SavedRegionTableViewCell.swift
//  PoForecast
//
//  Created by Paul Lee on 2022/09/05.
//

import UIKit

class SavedRegionTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var minMaxTempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        currentWeatherLabel.text = "-"
        currentTempLabel.text = "-"
        minMaxTempLabel.text = "-"
        
        contentView.layer.cornerRadius = 15
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
