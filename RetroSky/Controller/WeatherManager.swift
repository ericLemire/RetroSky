//
//  WeatherManager.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/11.
//


import Foundation
import CoreLocation

/// Delegate for asynchronous weather data updates and error handling.
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailToFetchWeatherWithError(error: WeatherManagerError)
}

/// Manages operations related to fetching and parsing weather data.
struct WeatherManager {
    // Injected dependencies for forming URLs, making network requests, and parsing JSON.
    let urlBuilder: URLBuilderProtocol
    let networkService: NetworkServiceProtocol
    let jsonParser: JSONParserProtocol
    
    // API key is initially loaded from environment variables then saved and retrieved from the Keychain for better security.
    let apiKey: String?
    let keychainService = KeychainService()

    var delegate: WeatherManagerDelegate?
    
    init(urlBuilder: URLBuilderProtocol, networkService: NetworkServiceProtocol, jsonParser: JSONParserProtocol) {
        self.urlBuilder = urlBuilder
        self.networkService = networkService
        self.jsonParser = jsonParser

        // Attempt to retrieve the API key from the Keychain
        if let key = keychainService.retrieveApiKey() {
            self.apiKey = key
        } else {
            // If not in Keychain, try to load from environment variables
            let key = ProcessInfo.processInfo.environment["API_KEY"]
            self.apiKey = key
            // If the key is found, save it to the Keychain for future use
            if let key = key {
                keychainService.saveApiKey(key)
            }
        }
    }

    /// Fetches and updates weather data based on given geographic coordinates.
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        // Guard against missing API key.
        guard let apiKey = self.apiKey else {
            print("API Key Error: No API key found.") 
            delegate?.didFailToFetchWeatherWithError(error: .apiKeyNotFound)
            return
        }

        let urlString = urlBuilder.urlForCoordinates(latitude: latitude, longitude: longitude, apiKey: apiKey)
        
        // Initiates network request to fetch weather data.
        networkService.performRequest(with: urlString) { data, error in
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                delegate?.didFailToFetchWeatherWithError(error: .networkError(error))
                return
            }

            // Proceeds to parsing and model update if data exists, otherwise triggers error.
            if let safeData = data {
                switch jsonParser.parseJSON(safeData) {
                case .success(let weather):
                    delegate?.didUpdateWeather(self, weather: weather)
                case .failure(let error):
                    print("Parsing Error: \(error)")
                    delegate?.didFailToFetchWeatherWithError(error: .parsingError)
                }
            } else {
                print("Data Error: Data is nil or corrupted.")
                delegate?.didFailToFetchWeatherWithError(error: .parsingError)
            }
        }
    }
}




