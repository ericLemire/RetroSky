//
//  HourlyForecastCell.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/16.
//

import UIKit

class HourlyForecastCell: UICollectionViewCell {
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        styleCell()
    }
    
    func configure(with model: HourForecast, formatter: TemperatureFormatter) {
        let temperatureText = model.temperatureC.map { "\(formatter.formattedTemperature(for: $0))°" } ?? "--"
        
        switch model.specialEvent {
        case .sunrise:
            hourLabel.text = model.sunriseTime ?? "Sunrise"
            weatherIcon.image = UIImage(named: model.weatherIconName)
            tempLabel.text = "Sunrise"
        case .sunset:
            hourLabel.text = model.sunsetTime ?? "Sunset"
            weatherIcon.image = UIImage(named: model.weatherIconName)
            tempLabel.text = "Sunset"
        case .none:
            hourLabel.text = model.time
            weatherIcon.image = UIImage(named: model.weatherIconName)
            tempLabel.text = temperatureText
        }
    }
    
    func styleCell() {
        // Retains the font size set in Storyboards
        if let currentFontSize = hourLabel.font?.pointSize {
            hourLabel.font = UIFont(name: "PixeloidSans", size: currentFontSize)
            tempLabel.font = UIFont(name: "PixeloidSans", size: currentFontSize)
        }
    }
}
