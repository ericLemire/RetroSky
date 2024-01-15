//
//  WeatherJSONParser.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/20.
//

import Foundation

protocol JSONParserProtocol {
    func parseJSON(_ data: Data) -> Result<WeatherModel, Error>
}

/// Enum to distinguish between today's and tomorrow's forecast when creating hourly forecast.
enum DayType: Int {
    case today = 0
    case tomorrow = 1
}

// TO DO: - Reduce Class Responsibility - separate weather decoding and date formatting logic
struct WeatherJSONParser: JSONParserProtocol {
    // Constants chosen for their significance in the forecast logic.
    private let forecastDays = 3
    private var currentHour: Int {
        return Calendar.current.component(.hour, from: Date())
    }
    // Custom date formatters for handling varied date formats in API response.
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()
    
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale.current
        return formatter
    }()
    
    /// Main parsing method that either returns a successfully parsed WeatherModel or an error.
    func parseJSON(_ data: Data) -> Result<WeatherModel, Error> {
        do {
            print("JSONParser: Parsing weather data")
            let decodedData = try decodeWeatherResponse(from: data)
            let weather = createWeatherModelInstance(with: decodedData)
            return .success(weather)
        } catch let error as WeatherParserError {
            print("JSONParser: WeatherParserError encountered: \(error)")
            error.logError()
            return .failure(error)
        } catch {
            print("JSONParser: Unexpected error: \(error.localizedDescription)")
           
            // If the error is not of WeatherParserError type, create a general parsing error with details.
            let detailedError = WeatherParserError.decodingError(detail: error.localizedDescription)
            detailedError.logError()
            return .failure(detailedError)
        }
    }
    
    private func decodeWeatherResponse(from data: Data) throws -> WeatherResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = customDateDecodingStrategy()
        return try decoder.decode(WeatherResponse.self, from: data)
    }
    
    /// Decodes JSON with a custom date decoding strategy to handle multiple date formats.
    private func customDateDecodingStrategy() -> JSONDecoder.DateDecodingStrategy {
        return .custom({ decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Determines the date format based on the length of the incoming date string.
            // Two expected formats:
            // 1) "yyyy-MM-dd HH:mm" when the length is 16 (includes date and time)
            // 2) "yyyy-MM-dd" when length is 10 (includes only the date)
            // Throws an error for any other lengths to catch malformed or unexpected date strings.
            if dateString.count == 16 { // Date and Time: "2023-09-20 22:45"
                WeatherJSONParser.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            } else if dateString.count == 10 { // Only Date: "2023-09-20"
                WeatherJSONParser.dateFormatter.dateFormat = "yyyy-MM-dd"
            } else {
                throw WeatherParserError.unexpectedTimeFormat(detail: "There was an unexpected time format.")
            }
            
            guard let date = WeatherJSONParser.dateFormatter.date(from: dateString) else {
                throw WeatherParserError.dateError(detail: "There was a problem with the date.")
            }
            return date
        })
    }
    
    /// Populates a WeatherModel instance from decoded JSON data.
    private func createWeatherModelInstance(with decodedData: WeatherResponse) -> WeatherModel {
        let cityName = decodedData.location.name
        let conditionId = decodedData.current.condition.code
        let temperatureC = decodedData.current.tempC
        let feelsLikeC = decodedData.current.feelslikeC
        let humidity = decodedData.current.humidity
        let isDay = decodedData.current.isDay
        
        return WeatherModel(conditionId: conditionId,
                            cityName: cityName,
                            temperatureC: temperatureC,
                            feelsLikeC: feelsLikeC, 
                            isDay: isDay,
                            humidity: humidity,
                            dailyForecast: createDailyForecast(with: decodedData, for: forecastDays),
                            hourlyForecast: createHourlyForecast(with: decodedData))
    }
    
    /// Generates a daily forecast array by using the API data up to `numOfDays`
    private func createDailyForecast(with decodedData: WeatherResponse, for numOfDays: Int) -> [DayForecast] {
        var dailyForecast = [DayForecast]()
        
        for i in 0..<min(numOfDays, decodedData.forecast.forecastday.count) {
            let date = decodedData.forecast.forecastday[i].date
            let dayOfWeek = WeatherJSONParser.dayFormatter.string(from: date)
            let shortDayOfWeek = String(dayOfWeek.prefix(3))
            
            let day = DayForecast(day: shortDayOfWeek,
                                  conditionId: decodedData.forecast.forecastday[i].day.condition.code,
                                  highC: decodedData.forecast.forecastday[i].day.maxtempC,
                                  lowC: decodedData.forecast.forecastday[i].day.mintempC, chanceOfRain: decodedData.forecast.forecastday[i].day.dailyChanceOfRain, chanceOfSnow: decodedData.forecast.forecastday[i].day.dailyChanceOfSnow)
            
            dailyForecast.append(day)
        }
        return dailyForecast
    }
    
    /// Divides the hourly forecast data between today and tomorrow based on the current hour.
    private func createHourlyForecast(with decodedData: WeatherResponse) -> [HourForecast] {
        let hoursLeftToday = 24 - currentHour
        let todayHourlyData = extractHourlyData(for: .today, from: decodedData.forecast.forecastday[0], neededHours: hoursLeftToday)

        // Calculate the number of hours needed from tomorrow to complete the 24-hour period
        let hoursNeededFromTomorrow = 24 - todayHourlyData.count
        var tomorrowHourlyData: [HourForecast] = []
        if hoursNeededFromTomorrow > 0 && decodedData.forecast.forecastday.count > 1 {
            tomorrowHourlyData = extractHourlyData(for: .tomorrow, from: decodedData.forecast.forecastday[1], neededHours: hoursNeededFromTomorrow)
        }
        
        let todaysSunEvents = getSunEvents(for: .today, from: decodedData)
        let todaysCompleteHourlyForecasts = insertSunEventsIntoHourlyForecasts(sunEvents: todaysSunEvents, hourlyForecasts: todayHourlyData)
       
        let tomorrowsSunEvents = getSunEvents(for: .tomorrow, from: decodedData)
        let tomorrowsCompletedHourlyForecasts = insertSunEventsIntoHourlyForecasts(sunEvents: tomorrowsSunEvents, hourlyForecasts: tomorrowHourlyData)
        
        // Combine today's and tomorrow's hourly data for processing
        var completeHourlyForecast = todaysCompleteHourlyForecasts + tomorrowsCompletedHourlyForecasts
        
        // Update the first hour to say "Now"
        if !completeHourlyForecast.isEmpty {
            completeHourlyForecast[0].time = "Now"
        }
        
        return completeHourlyForecast
    }
  
    private func getSunEvents(for day: DayType, from data: WeatherResponse) -> [HourForecast] {
        let sunriseString12hr = data.forecast.forecastday[day.rawValue].astro.sunrise
        let sunsetString12hr = data.forecast.forecastday[day.rawValue].astro.sunset

        // Set up a DateFormatter to convert the 12-hour time to a 24-hour format
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone.current

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.current

        // Convert the sunrise and sunset times to 24-hour format
        guard let sunriseDate = dateFormatter.date(from: sunriseString12hr),
              let sunsetDate = dateFormatter.date(from: sunsetString12hr) else {
            print("Unable to parse sunrise or sunset times.")
            return []
        }

        let sunriseTime24hr = outputFormatter.string(from: sunriseDate)
        let sunsetTime24hr = outputFormatter.string(from: sunsetDate)

        var sunEvents: [HourForecast] = []

        // Create and append sunrise event
        let sunriseEvent = HourForecast(time: sunriseTime24hr, conditionId: nil, temperatureC: nil, chanceOfRain: nil, chanceOfSnow: nil, specialEvent: .sunrise, sunriseTime: sunriseTime24hr, sunsetTime: nil, isDay: nil)
        sunEvents.append(sunriseEvent)

        // Create and append sunset event
        let sunsetEvent = HourForecast(time: sunsetTime24hr, conditionId: nil, temperatureC: nil, chanceOfRain: nil, chanceOfSnow: nil, specialEvent: .sunset, sunriseTime: nil, sunsetTime: sunsetTime24hr, isDay: nil)
        sunEvents.append(sunsetEvent)

        return sunEvents
    }

    func insertSunEventsIntoHourlyForecasts(sunEvents: [HourForecast], hourlyForecasts: [HourForecast]) -> [HourForecast] {
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
    private func extractHourlyData(for dayType: DayType, from forecastDay: Forecastday, neededHours: Int) -> [HourForecast] {
        var hourlyForecasts = [HourForecast]()
        var count = 0

        for (index, hourData) in forecastDay.hour.enumerated() {
            guard let extractedHour = try? extractHour(from: hourData.time),
                  let hourInt = Int(extractedHour) else {
                continue
            }
            
            if (dayType == .today && hourInt >= currentHour) || dayType == .tomorrow {
                let hourForecast = HourForecast(time: extractedHour, conditionId: hourData.condition.code, temperatureC: hourData.tempC, chanceOfRain: hourData.chanceOfRain, chanceOfSnow: nil, specialEvent: .none,  sunriseTime: forecastDay.astro.sunrise, sunsetTime: forecastDay.astro.sunset, isDay: forecastDay.hour[index].isDay)
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
    private func extractHour(from timeString: String) throws -> String {
        let timeComponents = timeString.split(separator: " ")
        if timeComponents.count > 1 {
            let hourComponents = timeComponents[1].split(separator: ":")
            return String(hourComponents[0])
        }
        throw WeatherParserError.unexpectedTimeFormat(detail: "There was a problem when attempting to extract the hour from the time string.")
    }
}


