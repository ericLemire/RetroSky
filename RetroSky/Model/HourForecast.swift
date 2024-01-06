//
//  HourForecast.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/20.
//

import Foundation

enum SunriseSunsetEvent {
    case sunrise
    case sunset
    case none
}

struct HourForecast {
    var time: String
    var conditionId: Int?
    var temperatureC: Double?
    let chanceOf: String?
    let specialEvent: SunriseSunsetEvent
    let sunriseTime: String?  
    let sunsetTime: String? 
    let isDay: Bool?
    
    var weatherIconName: String {
        switch specialEvent {
        case .sunrise:
            return "sunrise"
        case .sunset:
            return "sunset" 
        case .none:
            if let condition = conditionId, let weatherCondition = WeatherModel.weatherCodeMap[condition] {
                let imageName = WeatherVisualRepresentation.imageName(for: weatherCondition.weatherType, isDay: isDay ?? true)
                return imageName
            } else {
                return "partlyCloudy2"
            }
        }
    }
}

