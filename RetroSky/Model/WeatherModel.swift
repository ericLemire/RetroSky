//
//  WeatherModel.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/11.
//

import Foundation

struct WeatherModel {
    let conditionId: Int
    let cityName: String
    let temperatureC: Double
    let feelsLikeC: Double
    let isDay: Bool
    
    let humidity: Int
    
    let dailyForecast: [DayForecast]
    let hourlyForecast: [HourForecast]
    
    var temperatureString: String {
        return (String(format: "%.1f", temperatureC))
    }
    
    var weatherType: WeatherType {
        if let weatherCondition = WeatherModel.weatherCodeMap[conditionId] {
            return weatherCondition.weatherType
        } else {
            // Fallback image name if conditionId is not found
            return .partlyCloudy
        }
    }
    
    /// A mapping from API weather condition codes to internal weather conditions and descriptions.
    /// This allows for easy conversion and understanding of the API's numerical weather codes.
    static let weatherCodeMap: [Int: WeatherCondition] = [
        //Sun
        1000: WeatherCondition(code: 1000, weatherType: .clear, description: "Clear"),
        
        // Partially Cloudy
        1003: WeatherCondition(code: 1003, weatherType: .partlyCloudy, description: "Partly Cloudy"),
        
        // Cloudy
        1006: WeatherCondition(code: 1006, weatherType: .cloudy, description: "Cloudy"),
        1009: WeatherCondition(code: 1009, weatherType: .cloudy, description: "Overcast"),
        
        // Foggy
        1030: WeatherCondition(code: 1030, weatherType: .fog, description: "Mist"),
        1135: WeatherCondition(code: 1135, weatherType: .fog, description: "Fog"),
        1147: WeatherCondition(code: 1147, weatherType: .fog, description: "Freezing Fog"),
        
        // Stormy
        1087: WeatherCondition(code: 1087, weatherType: .storm, description: "Thundery Outbreaks Possible"),
        1273: WeatherCondition(code: 1273, weatherType: .storm, description: "Patchy Light Rain with Thunder"),
        1276: WeatherCondition(code: 1276, weatherType: .storm, description: "Moderate or Heavy Rain with Thunder"),
        
        // Drizzle
        1063: WeatherCondition(code: 1063, weatherType: .drizzle, description: "Patchy Rain Possible"),
        1069: WeatherCondition(code: 1069, weatherType: .drizzle, description: "Patchy Sleet Possible"),
        1072: WeatherCondition(code: 1072, weatherType: .drizzle, description: "Patchy Freezing Drizzle Possible"),
        1150: WeatherCondition(code: 1150, weatherType: .drizzle, description: "Patchy Light Drizzle"),
        1153: WeatherCondition(code: 1153, weatherType: .drizzle, description: "Light Drizzle"),
        1198: WeatherCondition(code: 1198, weatherType: .drizzle, description: "Light Freezing Rain"),
        
        // Rain
        1180: WeatherCondition(code: 1180, weatherType: .rain, description: "Patchy Light Rain"),
        1183: WeatherCondition(code: 1183, weatherType: .rain, description: "Light Rain"),
        1186: WeatherCondition(code: 1186, weatherType: .rain, description: "Moderate Rain at Times"),
        1189: WeatherCondition(code: 1189, weatherType: .rain, description: "Moderate Rain"),
        1192: WeatherCondition(code: 1192, weatherType: .rain, description: "Heavy Rain at Times"),
        1195: WeatherCondition(code: 1195, weatherType: .rain, description: "Heavy Rain"),
        1240: WeatherCondition(code: 1240, weatherType: .rain, description: "Light Showers"),
        1243: WeatherCondition(code: 1243, weatherType: .rain, description: "Moderate or Heavy Showers"),
        1246: WeatherCondition(code: 1246, weatherType: .rain, description: "Torrential Rain Shower"),
        
        // Snow
        1168: WeatherCondition(code: 1168, weatherType: .snow, description: "Freezing Drizzle"),
        1171: WeatherCondition(code: 1171, weatherType: .snow, description: "Heavy Freezing Drizzle"),
        1201: WeatherCondition(code: 1201, weatherType: .snow, description: "Moderate or Heavy Freezing Rain"),
        1066: WeatherCondition(code: 1066, weatherType: .snow, description: "Patchy Snow Possible"),
        1204: WeatherCondition(code: 1204, weatherType: .snow, description: "Light Sleet"),
        1207: WeatherCondition(code: 1207, weatherType: .snow, description: "Moderate or Heavy Sleet"),
        1210: WeatherCondition(code: 1210, weatherType: .snow, description: "Patchy Light Snow"),
        1213: WeatherCondition(code: 1213, weatherType: .snow, description: "Light Snow"),
        1216: WeatherCondition(code: 1216, weatherType: .snow, description: "Patchy Moderate Snow"),
        1219: WeatherCondition(code: 1219, weatherType: .snow, description: "Moderate Snow"),
        1222: WeatherCondition(code: 1222, weatherType: .snow, description: "Patchy Heavy Snow"),
        1225: WeatherCondition(code: 1225, weatherType: .snow, description: "Heavy Snow"),
        1237: WeatherCondition(code: 1237, weatherType: .snow, description: "Ice Pellets"),
        1249: WeatherCondition(code: 1249, weatherType: .snow, description: "Light Sleet Showers"),
        1252: WeatherCondition(code: 1252, weatherType: .snow, description: "Moderate or Heavy Sleet Showers"),
        1255: WeatherCondition(code: 1255, weatherType: .snow, description: "Light Snow Showers"),
        1258: WeatherCondition(code: 1258, weatherType: .snow, description: "Moderate or Heavy Snow Showers"),
        1261: WeatherCondition(code: 1261, weatherType: .snow, description: "Light Showers of Ice Pellets"),
        1264: WeatherCondition(code: 1264, weatherType: .snow, description: "Moderate or Heavy Showers of Ice Pellets"),
        1114: WeatherCondition(code: 1114, weatherType: .snow, description: "Blowing Snow"),
        1117: WeatherCondition(code: 1117, weatherType: .snow, description: "Blizzard"),
        1279: WeatherCondition(code: 1279, weatherType: .snow, description: "Patchy Light Snow with Thunder"),
        1282: WeatherCondition(code: 1282, weatherType: .snow, description: "Moderate or Heavy Snow with Thunder")
    ]
}




