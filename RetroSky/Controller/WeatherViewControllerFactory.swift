//
//  WeatherViewControllerFactory.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/23.
//

import Foundation

/// Initializes the urlBuilder, networkServices and jsonParser objects before injecting them into the weatherViewController
class WeatherViewControllerFactory {
    // Called in the SceneDelegate in order to initialize the necessary objects belonging to the weatherManager outside of the WeatherViewController
    static func createWeatherViewController() -> WeatherViewController {
        let urlBuilder = WeatherURLBuilder()
        let networkService = WeatherNetworkService()
        let jsonParser = WeatherJSONParser()
        
        let weatherManager = WeatherManager(urlBuilder: urlBuilder,
                                            networkService: networkService,
                                            jsonParser: jsonParser)
        
        let viewController = WeatherViewController()
        viewController.weatherManager = weatherManager
        
        return viewController
    }
}

