//
//  WeatherViewController+LocationManager.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/22.
//

import UIKit
import CoreLocation

extension WeatherViewController: CLLocationManagerDelegate {
    // Constants for alert messages are placed within this extension for better contextual grouping.
    static let locationDisabledTitle = "Location Access Disabled"
    static let locationDisabledMessage = "To enable weather updates based on your location, please open this app's settings and set location access to 'While Using the App'."
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Requests immediate location and starts significant change monitoring, if available.
            locationManager.requestLocation()
            if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                locationManager.startMonitoringSignificantLocationChanges()
            }
        case .restricted, .denied:
            // Prompts for setting changes if access denied.
            DispatchQueue.main.async {
                AlertUtility.showAlert(
                    on: self,
                    title: WeatherViewController.locationDisabledMessage,
                    // Detailed message to guide user through enabling location services.
                    message: WeatherViewController.locationDisabledMessage,
                    actions: [
                        UIAlertAction(title: "Go to Settings", style: .default, handler: self.goToSettings),
                        UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    ]
                )
            }
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            // Fallback for unexpected authorization statuses.
            print("Unexpected authorization status: \(manager.authorizationStatus)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            // Caches last-known coordinates for possible retries.
            lastKnownLatitude = location.coordinate.latitude
            lastKnownLongitude = location.coordinate.longitude
            
            // Triggers weather data fetch if coordinates are non-nil.
            if let latitude = lastKnownLatitude, let longitude = lastKnownLongitude {
                weatherManager.fetchWeather(latitude: latitude, longitude: longitude)
            } else {
                // Unlikely but handles nil coordinate scenario.
                AlertUtility.showAlert(on: self, title: "Location Unavailable", message: "Retry or check location settings.")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Displays a UIAlert with the localized error description.
        DispatchQueue.main.async {
            AlertUtility.showAlert(on: self, title: "Error", message: error.localizedDescription)
        }
    }
    
    func goToSettings(action: UIAlertAction) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}



