//
//  TemperatureFormatter.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/23.
//

import Foundation

enum TemperatureUnit {
    case celsius
    case fahrenheit
}

/// Handles the formatting of temperature values based on the user's locale.
struct TemperatureFormatter {
    // Constants for converting Celsius to Fahrenheit.
    static let fahrenheitConversionCoefficient = 9.0 / 5.0
    static let fahrenheitOffset = 32.0
    
    // A number formatter for converting numbers to localized string representations.
    let numberFormatter = NumberFormatter()
    let usesFahrenheitRegions = ["US", "LR", "MM"]
    let locale = Locale.current
    
    /// Determines the unit of temperature based on the user's region.
    var unit: TemperatureUnit {
        // If the user's region uses Fahrenheit, return that. Otherwise, return Celsius.
        if let regionCode = locale.regionCode, usesFahrenheitRegions.contains(regionCode) {
            return .fahrenheit
        }
        return .celsius
    }
    
    /// A convenience property to determine if Fahrenheit should be used.
    /// This is used to set the temperature notation text from Weather View Controller.
    var usesFahrenheit: Bool {
         // Return true if the user's region uses Fahrenheit; otherwise, default to false (Celsius).
         if let regionCode = locale.regionCode {
             return usesFahrenheitRegions.contains(regionCode)
         }
         return false
     }
        
    /// Formats a temperature value to a string based on the user's locale.
    /// - Parameter value: The temperature value to format.
    /// - Returns: A formatted temperature string.
    func formattedTemperature(for value: Double) -> String {
        let convertedTemp: Double
        
        // Convert the temperature based on the preferred unit.
        switch unit {
        case .fahrenheit:
            convertedTemp = (value * Self.fahrenheitConversionCoefficient) + Self.fahrenheitOffset
        case .celsius:
            convertedTemp = value
        }
        
        // Use numberFormatter to create a formatted string from the converted temperature.
        if let formattedString = numberFormatter.string(from: NSNumber(value: convertedTemp)) {
            return formattedString
        }
        
        // If formatting fails, default to returning the original value as a string.
        return String(convertedTemp)
    }
}


