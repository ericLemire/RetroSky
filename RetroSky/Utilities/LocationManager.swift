//
//  LocationManager.swift
//  RetroSky
//
//  Created by Eric Lemire on 2024/02/10.
//

import CoreLocation

protocol LocationManagerProtocol {
    var delegate: LocationManagerDelegate? { get set }
    func requestLocationUpdates()
    func stopLocationUpdates()
    func checkLocationServicesAndRequestLocation()
}

protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocations(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees)
    func didFailWithError(_ error: Error)
    func authorizationWasDenied()
    func authorizationIsRestricted()
}

class LocationManager: NSObject, CLLocationManagerDelegate, LocationManagerProtocol {
    private let cLLocationManager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?
    
    override init() {
        super.init()
        cLLocationManager.delegate = self
    }
    
    func checkLocationServicesAndRequestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            cLLocationManager.requestLocation()
        } else {
            delegate?.didFailWithError(LocationError.locationServicesDisabled)
        }
    }
    
    func requestLocationUpdates() {
        cLLocationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            cLLocationManager.startUpdatingLocation()
        }
    }
    
    func stopLocationUpdates() {
        cLLocationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted:
            delegate?.authorizationIsRestricted()
        case .denied:
            delegate?.authorizationWasDenied()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            // Fallback for unexpected authorization statuses.
            print("Unexpected authorization status: \(manager.authorizationStatus)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.didUpdateLocations(location.coordinate.latitude, location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailWithError(error)
    }
}
