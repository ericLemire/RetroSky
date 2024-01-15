//
//  ThreeDayForecastCell.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/16.
//

import UIKit

class DailyForecastCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var chanceOfLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        styleCell()
    }
    
    func configure(with model: DayForecast, formatter: TemperatureFormatter) {
        dayLabel.text = model.day
        highTempLabel.text = "H: \(formatter.formattedTemperature(for: model.highC))°"
        lowTempLabel.text = "L: \(formatter.formattedTemperature(for: model.lowC))°"
        weatherIcon.image = UIImage(named: model.weatherIconName)
        
        switch model.weatherIconName {
        case "rain", "nightRain", "rainStorm", "nightRainStorm":
            chanceOfLabel.isHidden = false
            chanceOfLabel.text = "\(model.chanceOfRain ?? 50)%"
        case "snow", "nightSnow":
            chanceOfLabel.isHidden = false
            chanceOfLabel.text = "\(model.chanceOfSnow ?? 50)%"
        default:
            chanceOfLabel.isHidden = true
        }
    }
    
    func styleCell() {
        if let currentFontSize = dayLabel.font?.pointSize {
            dayLabel.font = UIFont(name: "PixeloidSans", size: currentFontSize)
            lowTempLabel.font = UIFont(name: "PixeloidSans", size: currentFontSize)
            highTempLabel.font = UIFont(name: "PixeloidSans", size: currentFontSize)
        }
        if let chanceOfFontSize = chanceOfLabel.font?.pointSize {
            chanceOfLabel.font = UIFont(name: "PixeloidSans", size: chanceOfFontSize)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        chanceOfLabel.isHidden = true
    }
}
