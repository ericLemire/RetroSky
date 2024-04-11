//
//  ErrorEnums.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/21.
//

import Foundation

enum LocationError: Error {
    case locationServicesDisabled
    case authorizationDenied
    case authorizationRestricted
}

extension LocationError {
    var description: String {
        switch self {
        case .locationServicesDisabled:
            return "Location services are disabled."
        case .authorizationDenied:
            return "Location authorization was denied."
        case .authorizationRestricted:
            return "Location authorization is restricted."
        }
    }
}

enum WeatherManagerError: Error {
    case parsingError
    case networkError(Error)
    case apiKeyNotFound
    case locationError(Error)

    
    var userFriendlyAlertMessage: String {
        switch self {
        case .parsingError:
            return "We encountered an issue while processing the weather data. If the problem persists, please contact the developer."
        case .networkError(let underlyingError):
            print("Network Error: \(underlyingError.localizedDescription)") 
            return "A network error occurred. Please check your internet connection and try again."
        case .apiKeyNotFound:
            return "We're having trouble accessing the weather service. If the problem persists, please contact the developer."
        case .locationError(let underlyingError):
            print("Location Error: \(underlyingError.localizedDescription)")
            return "A location error occurred. Please ensure location services are enabled and try again."
        }
    }
}

enum WeatherParserError: Error {
    case decodingError(detail: String)
    case dateError(detail: String)
    case unexpectedTimeFormat(detail: String)
    case insufficientForecastData(detail: String)
}

extension WeatherParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .decodingError:
            return NSLocalizedString("Failed to decode the weather data.", comment: "Decoding Error")
        case .dateError:
            return NSLocalizedString("Failed to parse the date from the weather data.", comment: "Date Error")
        case .unexpectedTimeFormat:
            return NSLocalizedString("The time format in the weather data is unexpected.", comment: "Unexpected Time Format")
        case .insufficientForecastData:
            return NSLocalizedString("Insufficient forecast data available.", comment: "Insufficient Data")
        }
    }
    
    public var detailedDescription: String {
        switch self {
        case .decodingError(let detail),
             .dateError(let detail),
             .unexpectedTimeFormat(let detail),
             .insufficientForecastData(let detail):
            return detail
        }
    }
}

extension WeatherParserError {
    func logError() {
        print("Error occurred: \(self.localizedDescription)")
    }
}
