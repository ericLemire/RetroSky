//
//  WeatherData.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/11.
//

import Foundation

//Structs that are directly mapping to the JSON structure returned by the weather API.

// MARK: - WeatherResponse
struct WeatherResponse: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast
}

// MARK: - Location
struct Location: Codable {
    let name, region, country: String
    let lat, lon: Double
    let tzID: String
    let localtimeEpoch: Int
    let localtime: String

    enum CodingKeys: String, CodingKey {
        case name, region, country, lat, lon
        case tzID = "tz_id"
        case localtimeEpoch = "localtime_epoch"
        case localtime
    }
}

// MARK: - Current
struct Current: Codable {
    let lastUpdatedEpoch: Int
    let lastUpdated: String
    let tempC: Double
    let isDay: Bool  // Changed to Bool
    let condition: Condition
    let windMph, windKph: Double
    let humidity, cloud: Int
    let feelslikeC, uv: Double

    enum CodingKeys: String, CodingKey {
        case lastUpdatedEpoch = "last_updated_epoch"
        case lastUpdated = "last_updated"
        case tempC = "temp_c"
        case isDay = "is_day"
        case condition
        case windMph = "wind_mph"
        case windKph = "wind_kph"
        case humidity, cloud
        case feelslikeC = "feelslike_c"
        case uv
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lastUpdatedEpoch = try container.decode(Int.self, forKey: .lastUpdatedEpoch)
        lastUpdated = try container.decode(String.self, forKey: .lastUpdated)
        tempC = try container.decode(Double.self, forKey: .tempC)
        condition = try container.decode(Condition.self, forKey: .condition)
        windMph = try container.decode(Double.self, forKey: .windMph)
        windKph = try container.decode(Double.self, forKey: .windKph)
        humidity = try container.decode(Int.self, forKey: .humidity)
        cloud = try container.decode(Int.self, forKey: .cloud)
        feelslikeC = try container.decode(Double.self, forKey: .feelslikeC)
        uv = try container.decode(Double.self, forKey: .uv)

        // Decode isDay as Int and then convert to Bool
        let isDayValue = try container.decode(Int.self, forKey: .isDay)
        isDay = isDayValue == 1
    }
}


// MARK: - Condition
struct Condition: Codable {
    let text: String
    let icon: String
    let code: Int
}

// MARK: - Forecast
struct Forecast: Codable {
    let forecastday: [Forecastday]
}

// MARK: - Forecastday
struct Forecastday: Codable {
    let date: Date //***Changed from String
    let dateEpoch: Int
    let day: Day
    let astro: Astro
    let hour: [Hour]

    enum CodingKeys: String, CodingKey {
        case date
        case dateEpoch = "date_epoch"
        case day, astro, hour
    }
}

// MARK: - Astro
struct Astro: Codable {
    let sunrise, sunset, moonrise, moonset: String
    let moonPhase: String
    let moonIllumination: Int
    let isMoonUp, isSunUp: Int

    enum CodingKeys: String, CodingKey {
        case sunrise, sunset, moonrise, moonset
        case moonPhase = "moon_phase"
        case moonIllumination = "moon_illumination"
        case isMoonUp = "is_moon_up"
        case isSunUp = "is_sun_up"
    }
}

// MARK: - Day
struct Day: Codable {
    let maxtempC, mintempC: Double
    let avgtempC, totalsnowCm, avghumidity: Double
    let dailyWillItRain, dailyChanceOfRain, dailyWillItSnow, dailyChanceOfSnow: Int
    let condition: Condition
    let uv: Double

    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case avgtempC = "avgtemp_c"
        case totalsnowCm = "totalsnow_cm"
        case avghumidity
        case dailyWillItRain = "daily_will_it_rain"
        case dailyChanceOfRain = "daily_chance_of_rain"
        case dailyWillItSnow = "daily_will_it_snow"
        case dailyChanceOfSnow = "daily_chance_of_snow"
        case condition, uv
    }
}

// MARK: - Hour
struct Hour: Codable {
    let timeEpoch: Int
    let time: String
    let tempC: Double
    let isDay: Bool  // Changed to Bool
    let condition: Condition
    let willItRain, chanceOfRain, willItSnow, chanceOfSnow: Int

    enum CodingKeys: String, CodingKey {
        case timeEpoch = "time_epoch"
        case time
        case tempC = "temp_c"
        case isDay = "is_day"
        case condition
        case willItRain = "will_it_rain"
        case chanceOfRain = "chance_of_rain"
        case willItSnow = "will_it_snow"
        case chanceOfSnow = "chance_of_snow"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeEpoch = try container.decode(Int.self, forKey: .timeEpoch)
        time = try container.decode(String.self, forKey: .time)
        tempC = try container.decode(Double.self, forKey: .tempC)
        condition = try container.decode(Condition.self, forKey: .condition)
        willItRain = try container.decode(Int.self, forKey: .willItRain)
        chanceOfRain = try container.decode(Int.self, forKey: .chanceOfRain)
        willItSnow = try container.decode(Int.self, forKey: .willItSnow)
        chanceOfSnow = try container.decode(Int.self, forKey: .chanceOfSnow)

        // Decode isDay as Int and then convert to Bool
        let isDayValue = try container.decode(Int.self, forKey: .isDay)
        isDay = isDayValue == 1
    }
}



