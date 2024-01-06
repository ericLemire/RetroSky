//
//  DayForecast.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/20.
//

import Foundation

struct DayForecast {
    let day: String
    let conditionId: Int
    let highC: Double
    let lowC: Double
    
    var weatherIconName: String {
        if let weatherCondition = WeatherModel.weatherCodeMap[conditionId] {
            let imageName = WeatherVisualRepresentation.imageName(for: weatherCondition.weatherType, isDay: true)
            return imageName
        } else {
            return "partlyCloudy2"
        }
    }
}
