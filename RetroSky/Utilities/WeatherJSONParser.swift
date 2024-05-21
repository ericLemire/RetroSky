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

struct WeatherJSONParser: JSONParserProtocol {
    // Constants chosen for their significance in the forecast logic.
    private let forecastDays = 3

    // Custom date formatters for handling varied date formats in the API response.
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()

    /// Main parsing method that either returns a successfully parsed WeatherModel or an error.
    func parseJSON(_ data: Data) -> Result<WeatherModel, Error> {
        do {
            print("JSONParser: Parsing weather data")
            let decodedData = try decodeWeatherResponse(from: data)
            let weather = WeatherDataTransformer.transformWeatherResponse(decodedData, forecastDays: forecastDays)
            return .success(weather)
        } catch let error as WeatherParserError {
            print("JSONParser: WeatherParserError encountered: \(error)")
            error.logError()
            return .failure(error)
        } catch {
            print("JSONParser: Unexpected error: \(error.localizedDescription)")
            let detailedError = WeatherParserError.decodingError(detail: error.localizedDescription)
            detailedError.logError()
            return .failure(detailedError)
        }
    }

    /// Decodes the weather response from JSON data using a custom date decoding strategy.
    private func decodeWeatherResponse(from data: Data) throws -> WeatherResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = customDateDecodingStrategy()
        return try decoder.decode(WeatherResponse.self, from: data)
    }

    /// Custom date decoding strategy to handle multiple date formats in the JSON data.
    private func customDateDecodingStrategy() -> JSONDecoder.DateDecodingStrategy {
        return .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Determines the date format based on the length of the incoming date string.
            if dateString.count == 16 { // Date and Time: "yyyy-MM-dd HH:mm"
                WeatherJSONParser.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            } else if dateString.count == 10 { // Only Date: "yyyy-MM-dd"
                WeatherJSONParser.dateFormatter.dateFormat = "yyyy-MM-dd"
            } else {
                throw WeatherParserError.unexpectedTimeFormat(detail: "Unexpected date format: \(dateString)")
            }
            
            guard let date = WeatherJSONParser.dateFormatter.date(from: dateString) else {
                throw WeatherParserError.dateError(detail: "Invalid date format: \(dateString)")
            }
            return date
        }
    }
}




