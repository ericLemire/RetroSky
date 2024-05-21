//
//  WeatherDataTransformer.swift
//  RetroSky
//
//  Created by Eric Lemire on 2024/05/13.
//

import Foundation

struct WeatherDataTransformer {
    private static var currentHour: Int {
        return Calendar.current.component(.hour, from: Date())
    }
    
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale.current
        return formatter
    }()
    
    /// Transforms WeatherResponse to WeatherModel
    static func transformWeatherResponse(_ data: WeatherResponse, forecastDays: Int) -> WeatherModel {
        let dailyForecasts = generateDailyForecast(with: data, for: forecastDays)
        let hourlyForecasts = generateHourlyForecast(with: data)
        
        return WeatherModel(
            conditionId: data.current.condition.code,
            cityName: data.location.name,
            temperatureC: data.current.tempC,
            feelsLikeC: data.current.feelslikeC,
            isDay: data.current.isDay,
            humidity: data.current.humidity,
            dailyForecast: dailyForecasts,
            hourlyForecast: hourlyForecasts
        )
    }

    /// Generates a daily forecast array by using the API data up to `numOfDays`
    private static func generateDailyForecast(with decodedData: WeatherResponse, for numOfDays: Int) -> [DayForecast] {
        var dailyForecast = [DayForecast]()
        
        for i in 0..<min(numOfDays, decodedData.forecast.forecastday.count) {
            let forecastDay = decodedData.forecast.forecastday[i]
            let date = forecastDay.date
            let dayOfWeek = dayFormatter.string(from: date)
            let shortDayOfWeek = String(dayOfWeek.prefix(3))
            
            let day = DayForecast(
                day: shortDayOfWeek,
                conditionId: forecastDay.day.condition.code,
                highC: forecastDay.day.maxtempC,
                lowC: forecastDay.day.mintempC,
                chanceOfRain: forecastDay.day.dailyChanceOfRain,
                chanceOfSnow: forecastDay.day.dailyChanceOfSnow
            )
            dailyForecast.append(day)
        }
        return dailyForecast
    }
    
    /// Divides the hourly forecast data between today and tomorrow based on the current hour.
    private static func generateHourlyForecast(with decodedData: WeatherResponse) -> [HourForecast] {
        let hoursLeftToday = 24 - currentHour
        let todayHourlyData = extractRelevantHourlyData(for: .today, from: decodedData.forecast.forecastday[0], neededHours: hoursLeftToday)

        // Calculate the number of hours needed from tomorrow to complete the 24-hour period.
        let hoursNeededFromTomorrow = 24 - todayHourlyData.count
        var tomorrowHourlyData: [HourForecast] = []
        if hoursNeededFromTomorrow > 0 && decodedData.forecast.forecastday.count > 1 {
            tomorrowHourlyData = extractRelevantHourlyData(for: .tomorrow, from: decodedData.forecast.forecastday[1], neededHours: hoursNeededFromTomorrow)
        }
        
        let todaysSunEvents = retrieveSunEvents(for: .today, from: decodedData)
        let todaysCompleteHourlyForecasts = mergeSunEventsWithHourlyForecasts(sunEvents: todaysSunEvents, hourlyForecasts: todayHourlyData)
       
        let tomorrowsSunEvents = retrieveSunEvents(for: .tomorrow, from: decodedData)
        let tomorrowsCompletedHourlyForecasts = mergeSunEventsWithHourlyForecasts(sunEvents: tomorrowsSunEvents, hourlyForecasts: tomorrowHourlyData)
        
        // Combine today's and tomorrow's hourly data for processing.
        var completeHourlyForecast = todaysCompleteHourlyForecasts + tomorrowsCompletedHourlyForecasts
        
        // Update the first hour to say "Now".
        if !completeHourlyForecast.isEmpty {
            completeHourlyForecast[0].time = "Now"
        }
        
        return completeHourlyForecast
    }
  
    private static func retrieveSunEvents(for day: DayType, from data: WeatherResponse) -> [HourForecast] {
        let forecastDay = data.forecast.forecastday[day.rawValue]
        let sunriseString12hr = forecastDay.astro.sunrise
        let sunsetString12hr = forecastDay.astro.sunset

        // Set up a DateFormatter to convert the 12-hour time to a 24-hour format.
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone.current

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.current

        // Convert the sunrise and sunset times to 24-hour format.
        guard let sunriseDate = dateFormatter.date(from: sunriseString12hr),
              let sunsetDate = dateFormatter.date(from: sunsetString12hr) else {
            print("Unable to parse sunrise or sunset times.")
            return []
        }

        let sunriseTime24hr = outputFormatter.string(from: sunriseDate)
        let sunsetTime24hr = outputFormatter.string(from: sunsetDate)

        var sunEvents: [HourForecast] = []

        let sunriseEvent = HourForecast(
            time: sunriseTime24hr,
            conditionId: nil,
            temperatureC: nil,
            chanceOfRain: nil,
            chanceOfSnow: nil,
            specialEvent: .sunrise,
            sunriseTime: sunriseTime24hr,
            sunsetTime: nil,
            isDay: nil
        )
        sunEvents.append(sunriseEvent)

        let sunsetEvent = HourForecast(
            time: sunsetTime24hr,
            conditionId: nil,
            temperatureC: nil,
            chanceOfRain: nil,
            chanceOfSnow: nil,
            specialEvent: .sunset,
            sunriseTime: nil,
            sunsetTime: sunsetTime24hr,
            isDay: nil
        )
        sunEvents.append(sunsetEvent)

        return sunEvents
    }

    private static func mergeSunEventsWithHourlyForecasts(sunEvents: [HourForecast], hourlyForecasts: [HourForecast]) -> [HourForecast] {
        let filteredSortedSunEvents = sunEvents.sorted { $0.time < $1.time }
        var sortedHourlyForecasts = hourlyForecasts.sorted { $0.time < $1.time }

        for sunEvent in filteredSortedSunEvents {
            // Extract the hour part from the sun event time string.
            let sunEventHourPart = String(sunEvent.time.prefix(2))
            
            // Look for the first HourForecast object whose hour matches the sun event's hour.
            if let index = sortedHourlyForecasts.firstIndex(where: { String($0.time.prefix(2)) == sunEventHourPart }) {
                sortedHourlyForecasts.insert(sunEvent, at: index + 1)
            }
        }
        return sortedHourlyForecasts
    }
    
    /// Extracts only the relevant hours from the API response based on the current hour and day type.
    private static func extractRelevantHourlyData(for dayType: DayType, from forecastDay: Forecastday, neededHours: Int) -> [HourForecast] {
        var hourlyForecasts = [HourForecast]()
        var count = 0

        for hourData in forecastDay.hour {
            guard let extractedHour = try? extractHour(from: hourData.time),
                  let hourInt = Int(extractedHour) else {
                continue
            }
            
            if (dayType == .today && hourInt >= currentHour) || dayType == .tomorrow {
                let hourForecast = HourForecast(
                    time: extractedHour,
                    conditionId: hourData.condition.code,
                    temperatureC: hourData.tempC,
                    chanceOfRain: hourData.chanceOfRain,
                    chanceOfSnow: nil,
                    specialEvent: .none,
                    sunriseTime: forecastDay.astro.sunrise,
                    sunsetTime: forecastDay.astro.sunset,
                    isDay: hourData.isDay
                )
                hourlyForecasts.append(hourForecast)
                count += 1
                
                if count >= neededHours {
                    break
                }
            }
        }
        return hourlyForecasts
    }
    
    /// Utility function for extracting the hour from a datetime string.
    private static func extractHour(from timeString: String) throws -> String {
        let timeComponents = timeString.split(separator: " ")
        if timeComponents.count > 1 {
            let hourComponents = timeComponents[1].split(separator: ":")
            return String(hourComponents[0])
        }
        throw WeatherParserError.unexpectedTimeFormat(detail: "There was a problem when attempting to extract the hour from the time string.")
    }
}
