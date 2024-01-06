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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        styleCell()
    }
    
    func configure(with model: DayForecast, formatter: TemperatureFormatter) {
        dayLabel.text = model.day
        highTempLabel.text = "\(formatter.formattedTemperature(for: model.highC))°"
        lowTempLabel.text = "\(formatter.formattedTemperature(for: model.lowC))°"
        weatherIcon.image = UIImage(named: model.weatherIconName)
    }
    
    func styleCell() {
        if let currentFontSize = dayLabel.font?.pointSize {
            dayLabel.font = UIFont(name: "PixeloidSans", size: currentFontSize)
            lowTempLabel.font = UIFont(name: "PixeloidSans", size: currentFontSize)
            highTempLabel.font = UIFont(name: "PixeloidSans", size: currentFontSize)
        }
    }
}
