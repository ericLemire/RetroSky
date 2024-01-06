//
//  WeatherAnimator.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/10/23.
//

import UIKit

enum WeatherType {
    case clear
    case partlyCloudy
    case cloudy
    case fog
    case drizzle
    case rain
    case heavyRain
    case storm
    case rainStorm
    case snow
}

struct WeatherVisualRepresentation {
    
    // Returns the appropriate file name to display the weather icons based on the weather type and time of day.
    static func imageName(for weather: WeatherType, isDay: Bool) -> String {
        switch weather {
        case .clear:
            return isDay ? "clear" : "nightClear"
        case .partlyCloudy:
            return isDay ? "partlyCloudy" : "nightCloudy"
        case .cloudy:
            return isDay ? "cloudy" : "nightCloudy"
        case .fog:
            return isDay ? "fog" : "nightFog"
        case .drizzle:
            return isDay ? "rain" : "nightRain"
        case .rain:
            return isDay ? "rain" : "nightRain"
        case .heavyRain:
            return isDay ? "rain" : "nightRain"
        case .storm, .rainStorm:
            return isDay ? "storm" : "nightStorm"
        case .snow:
            return isDay ? "snow" : "nightSnow"
        }
    }
    
    // Returns the appropriate file names to display the animated weather background based on the weather type and time of day.
    static func animationConfig(for weather: WeatherType, isDay: Bool) -> (images: [UIImage], duration: Double) {
        switch weather {
        case .clear:
            let clearImages = ["clear1", "clear2", "clear3"].compactMap { UIImage(named: $0) }
            let nightClearImages = ["nightClear1", "nightClear2", "nightClear3", "nightClear4"].compactMap { UIImage(named: $0) }
            return isDay ? (images: clearImages, duration: 1.0) : (images: nightClearImages, duration: 1.0)
        case .partlyCloudy:
            let partlyCloudyImages = ["partlyCloudy1", "partlyCloudy2", "partlyCloudy3", "partlyCloudy4"].compactMap { UIImage(named: $0) }
            let nightPartlyCloudyImages = ["nightCloudy1", "nightCloudy2", "nightCloudy3", "nightCloudy4"].compactMap { UIImage(named: $0) }
            return isDay ? (images: partlyCloudyImages, duration: 1.5) : (images: nightPartlyCloudyImages, duration: 1.5)
        case .cloudy:
            let cloudyImages = ["cloudy1"].compactMap { UIImage(named: $0) }
            let nightCloudyImages = ["nightCloudy1", "nightCloudy2", "nightCloudy3", "nightCloudy4"].compactMap { UIImage(named: $0) }
            return isDay ? (images: cloudyImages, duration: 1.0) : (images: nightCloudyImages, duration: 1.0)
        case .drizzle:
            let drizzleImages = ["drizzle1", "drizzle2"].compactMap { UIImage(named: $0) }
            let nightDrizzleImages = ["nightRain1", "nightRain2", "nightRain3", "nightRain4"].compactMap { UIImage(named: $0) }
            return isDay ? (images: drizzleImages, duration: 1.0) : (images: nightDrizzleImages, duration: 1.0)
        case .fog:
            let fogImages = ["fog1", "fog2"].compactMap { UIImage(named: $0) }
            let nightFogImages = ["nightFog1", "nightFog2"].compactMap { UIImage(named: $0) }
            return isDay ? (images: fogImages, duration: 0.2) : (images: nightFogImages, duration: 0.2)
        case .rain:
            let rainImages = ["rain1", "rain2"].compactMap { UIImage(named: $0) }
            let nightRainImages = ["nightRain1", "nightRain2", "nightRain3", "nightRain4"].compactMap { UIImage(named: $0) }
            return isDay ? (images: rainImages, duration: 1.0) : (images: nightRainImages, duration: 1.0)
        case .heavyRain:
            let heavyRainImages = ["heavyRain1", "heavyRain2"].compactMap { UIImage(named: $0) }
            let nightHeavyRainImages = ["nightHeavyRain1", "nightHeavyRain2"].compactMap { UIImage(named: $0) }
            return isDay ? (images: heavyRainImages, duration: 1.0) : (images: nightHeavyRainImages, duration: 1.0)
        case .storm:
            let stormImages = ["storm1", "storm2", "storm3", "storm4", "storm5", "storm6"].compactMap { UIImage(named: $0) }
            let nightStormImages = ["nightStorm1", "nightStorm2", "nightStorm3", "nightStorm4", "nightStorm5", "nightStorm6"].compactMap { UIImage(named: $0) }
            return isDay ? (images: stormImages, duration: 1.0) : (images: nightStormImages, duration: 1.0)
        case .snow:
            let snowImages = ["snow1", "snow2"].compactMap { UIImage(named: $0) }
            let nightSnowImages = ["nightSnow1", "nightSnow2"].compactMap { UIImage(named: $0) }
            return isDay ? (images: snowImages, duration: 1.0) : (images: nightSnowImages, duration: 1.0)
        case .rainStorm:
            let rainStormImages = ["rainStorm1", "rainStorm2", "rainStorm3", "rainStorm4", "rainStorm5", "rainStorm6"].compactMap { UIImage(named: $0) }
            let nightRainStormImages = ["nightRainStorm1", "nightRainStorm2", "nightRainStorm3", "nightRainStorm4", "nightRainStorm5", "nightRainStorm6"].compactMap { UIImage(named: $0) }
            return isDay ? (images: rainStormImages, duration: 1.0) : (images: nightRainStormImages, duration: 1.0)
        }
    }
}
