//
//  WeatherURLBuilder.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/20.
//

import Foundation
import CoreLocation

// MARK: - URLBuilderProtocol

protocol URLBuilderProtocol {
    func urlForCity(_ cityName: String, apiKey: String) -> String
    func urlForCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees, apiKey: String) -> String
}

// MARK: - WeatherURLBuilder

/// Concrete implementation of the URLBuilderProtocol, specifically for building weather API URLs.
struct WeatherURLBuilder: URLBuilderProtocol {
    let baseURL = "https://api.weatherapi.com/v1/forecast.json"
    
    func urlForCity(_ cityName: String, apiKey: String) -> String {
        return "\(baseURL)?key=\(apiKey)&q=\(cityName)&days=3&aqi=no&alerts=no"
    }
    
    func urlForCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees, apiKey: String) -> String {
        return "\(baseURL)?key=\(apiKey)&q=\(latitude),\(longitude)&days=3&aqi=no&alerts=no"
    }
}

