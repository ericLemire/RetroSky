//
//  WeatherUtilities.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/23.
//

import Foundation

struct WeatherCondition {
    let code: Int
    let imageName: String
    let description: String
}

let weatherCodeMap: [Int: WeatherCondition] = [
    //Sun
    1000: WeatherCondition(code: 1000, imageName: "sun.max", description: "Clear"),
    
    // Partially Cloudy
    1003: WeatherCondition(code: 1003, imageName: "cloud.sun.fill", description: "Partly Cloudy"),
    
    // Cloudy
    1006: WeatherCondition(code: 1006, imageName: "cloud", description: "Cloudy"),
    1009: WeatherCondition(code: 1009, imageName: "cloud", description: "Overcast"),
    
    // Foggy
    1030: WeatherCondition(code: 1030, imageName: "cloud.fog", description: "Mist"),
    1135: WeatherCondition(code: 1135, imageName: "cloud.fog", description: "Fog"),
    1147: WeatherCondition(code: 1147, imageName: "cloud.fog", description: "Freezing Fog"),

    // Stormy
    1087: WeatherCondition(code: 1087, imageName: "cloud.bolt", description: "Thundery Outbreaks Possible"),
    1273: WeatherCondition(code: 1273, imageName: "cloud.bolt", description: "Patchy Light Rain with Thunder"),
    1276: WeatherCondition(code: 1276, imageName: "cloud.bolt", description: "Moderate or Heavy Rain with Thunder"),
    
    // Drizzle
    1063: WeatherCondition(code: 1063, imageName: "cloud.drizzle", description: "Patchy Rain Possible"),
    1069: WeatherCondition(code: 1069, imageName: "cloud.drizzle", description: "Patchy Sleet Possible"),
    1072: WeatherCondition(code: 1072, imageName: "cloud.drizzle", description: "Patchy Freezing Drizzle Possible"),
    1150: WeatherCondition(code: 1150, imageName: "cloud.drizzle", description: "Patchy Light Drizzle"),
    1153: WeatherCondition(code: 1153, imageName: "cloud.drizzle", description: "Light Drizzle"),
    1198: WeatherCondition(code: 1198, imageName: "cloud.drizzle", description: "Light Freezing Rain"),

    // Rain
    1180: WeatherCondition(code: 1180, imageName: "cloud.rain", description: "Patchy Light Rain"),
    1183: WeatherCondition(code: 1183, imageName: "cloud.rain", description: "Light Rain"),
    1186: WeatherCondition(code: 1186, imageName: "cloud.rain", description: "Moderate Rain at Times"),
    1189: WeatherCondition(code: 1189, imageName: "cloud.rain", description: "Moderate Rain"),
    1192: WeatherCondition(code: 1192, imageName: "cloud.rain", description: "Heavy Rain at Times"),
    1195: WeatherCondition(code: 1195, imageName: "cloud.rain", description: "Heavy Rain"),
    1240: WeatherCondition(code: 1240, imageName: "cloud.rain", description: "Light Showers"),
    1243: WeatherCondition(code: 1243, imageName: "cloud.rain", description: "Moderate or Heavy Showers"),
    1246: WeatherCondition(code: 1246, imageName: "cloud.rain", description: "Torrential Rain Shower"),
    
    // Snow
    1168: WeatherCondition(code: 1168, imageName: "cloud.snow", description: "Freezing Drizzle"),
    1171: WeatherCondition(code: 1171, imageName: "cloud.snow", description: "Heavy Freezing Drizzle"),
    1201: WeatherCondition(code: 1201, imageName: "cloud.snow", description: "Moderate or Heavy Freezing Rain"),
    1066: WeatherCondition(code: 1066, imageName: "cloud.snow", description: "Patchy Snow Possible"),
    1204: WeatherCondition(code: 1204, imageName: "cloud.snow", description: "Light Sleet"),
    1207: WeatherCondition(code: 1207, imageName: "cloud.snow", description: "Moderate or Heavy Sleet"),
    1210: WeatherCondition(code: 1210, imageName: "cloud.snow", description: "Patchy Light Snow"),
    1213: WeatherCondition(code: 1213, imageName: "cloud.snow", description: "Light Snow"),
    1216: WeatherCondition(code: 1216, imageName: "cloud.snow", description: "Patchy Moderate Snow"),
    1219: WeatherCondition(code: 1219, imageName: "cloud.snow", description: "Moderate Snow"),
    1222: WeatherCondition(code: 1222, imageName: "cloud.snow", description: "Patchy Heavy Snow"),
    1225: WeatherCondition(code: 1225, imageName: "cloud.snow", description: "Heavy Snow"),
    1237: WeatherCondition(code: 1237, imageName: "cloud.snow", description: "Ice Pellets"),
    1249: WeatherCondition(code: 1249, imageName: "cloud.snow", description: "Light Sleet Showers"),
    1252: WeatherCondition(code: 1252, imageName: "cloud.snow", description: "Moderate or Heavy Sleet Showers"),
    1255: WeatherCondition(code: 1255, imageName: "cloud.snow", description: "Light Snow Showers"),
    1258: WeatherCondition(code: 1258, imageName: "cloud.snow", description: "Moderate or Heavy Snow Showers"),
    1261: WeatherCondition(code: 1261, imageName: "cloud.snow", description: "Light Showers of Ice Pellets"),
    1264: WeatherCondition(code: 1264, imageName: "cloud.snow", description: "Moderate or Heavy Showers of Ice Pellets"),
    1114: WeatherCondition(code: 1114, imageName: "cloud.snow", description: "Blowing Snow"),
    1117: WeatherCondition(code: 1117, imageName: "cloud.snow", description: "Blizzard"),
    1279: WeatherCondition(code: 1279, imageName: "cloud.snow", description: "Patchy Light Snow with Thunder"),
    1282: WeatherCondition(code: 1282, imageName: "cloud.snow", description: "Moderate or Heavy Snow with Thunder")
]

    
    
    
//    static func getConditionName(for condition: Int) -> String {
//        switch condition {
//        case 200...232:
//            return "cloud.bolt"
//        case 300...321:
//            return "cloud.drizzle"
//        case 500...531:
//            return "cloud.rain"
//        case 600...622:
//            return "cloud.snow"
//        case 701...781:
//            return "cloud.fog"
//        case 1000:
//            return "sun.max"
//        case 801...804:
//            return "cloud.bolt"
//        default:
//            return "cloud"
//        }
//    }

