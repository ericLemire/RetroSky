//
//  ViewController.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/08/30.
//

//TODO: Refactor the WeatherViewController. Refactor The WeatherJSONParser, which is currently responsible for multiple tasks. Solve the mysterious purple warning. Solve the warnings in the log. Remove unnecessary print statements. Implement logging system. Create tests. Push to Github.

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    // MARK: - UI Outlets
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingAnimation: UIImageView!
    
    // UI elements responsible for showing current weather.

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperatureNotation: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var degreeSymbol: UILabel!
    @IBOutlet weak var weatherAnimationView: UIImageView!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var feelsLikeTemperatureLabel: UILabel!
    @IBOutlet weak var duck: UIImageView!
    
    // UI elements responsible for displaying forecast data.
    @IBOutlet weak var dailyForecastLabel: UILabel!
    @IBOutlet weak var hourlyForecastCollectionView: UICollectionView!
    @IBOutlet weak var dailyForecastCollectionView: UICollectionView!
    @IBOutlet weak var dailyForecastHeader: UILabel!
    
    // MARK: - Core Properties
    
    var isAlreadyLaunched = false

    // Cache last known geolocation in case of network retries.
    var lastKnownLatitude: CLLocationDegrees?
    var lastKnownLongitude: CLLocationDegrees?
    
    // Responsible for formatting temperature strings as either
    let temperatureFormatter = TemperatureFormatter()
    
    // Manages geolocation services to fetch and update the user's current location.
    let locationManager = CLLocationManager()
    
    var weatherManager: WeatherManager!
    
    // MARK: - Data Models
    
    // Caches hourly forecast data for use in the collection view.
    var hourlyForecast: [HourForecast] = []
    
    // Caches daily forecast data for use in the collection view.
    var dailyForecast: [DayForecast] = []
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setupLoadingAnimation()

        weatherManager.delegate = self
        locationManager.delegate = self
        
        // Configure temperature notation (e.g., Fahrenheit, Celsius) based on user location.
        setupTemperatureNotation()
        setupTemperatureUI()
        
        // Assigning data sources for forecast collection views
        hourlyForecastCollectionView.dataSource = self
        dailyForecastCollectionView.dataSource = self
        
        // Observer for app becoming active in order to trigger a weather data update
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func appDidBecomeActive() {
        if isAlreadyLaunched {
            refreshWeatherData()
        }
    }
    
    deinit {
        // Remove observers when the view controller is being deinitialized
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAlreadyLaunched = true
    }
    
    /// Configures how temperature is displayed, based on user or system settings.
    private func setupTemperatureNotation() {
        temperatureNotation.text = temperatureFormatter.usesFahrenheit ? "F" : "C"
    }

    // MARK: - Helper Methods
        
    func refreshWeatherData() {
        if CLLocationManager.locationServicesEnabled() {
            // Start updating location to trigger weather data fetch
            locationManager.startUpdatingLocation()
        } else {
            // Location services are not enabled; prompt the user
            AlertUtility.showAlert(on: self, title: "Location Services Disabled", message: "Please enable location services in your settings to fetch weather data.")
        }
    }
    
    func setupTemperatureUI() {
        let fontName = "PixeloidSans"
        setFont(for: temperatureLabel, with: fontName, size: 80)
        setFont(for: temperatureNotation, with: fontName, size: 80)
        setFont(for: degreeSymbol, with: fontName, size: 80)
        setFont(for: cityLabel, with: fontName, size: 42)
        setFont(for: dailyForecastLabel, with: fontName, size: 16)
        setFont(for: feelsLikeLabel, with: fontName, size: 17)
        setFont(for: feelsLikeTemperatureLabel, with: fontName, size: 60)
    }

    func setFont(for label: UILabel, with fontName: String, size: CGFloat) {
        label.font = UIFont(name: fontName, size: size)
    }
    
    /// Updates the main UI elements with new weather data.
    /// - Parameter weather: The WeatherModel instance containing the latest fetched data.
    func updateUI(with weatherData: WeatherModel) {
        DispatchQueue.main.async {
            
            print("Updating UI with new weather data for city: \(weatherData.cityName) with temperature: \(weatherData.temperatureC)°C and weather type: \(weatherData.weatherType)")

            self.temperatureLabel.text = self.temperatureFormatter.formattedTemperature(for: weatherData.temperatureC)
            self.cityLabel.text = weatherData.cityName
            self.animateWeatherImageView(with: weatherData.weatherType, and: weatherData)
            self.feelsLikeTemperatureLabel.text = "\(self.temperatureFormatter.formattedTemperature(for: weatherData.feelsLikeC))°C"
            
            // Refreshing collection view data
            self.dailyForecastCollectionView.reloadData()
            self.hourlyForecastCollectionView.reloadData()
            
            // Animate the transition
            UIView.transition(with: self.view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
                self.loadingView.isHidden = true
                self.hourlyForecastCollectionView.isHidden = false
                self.dailyForecastCollectionView.isHidden = false
                self.dailyForecastHeader.isHidden = false
            }, completion: nil)
            
            self.updateDuckAnimation(feelsLikeTemperature: weatherData.feelsLikeC, isDaytime: weatherData.isDay)
        }
    }
    
    /// Handles errors that occur while fetching weather data.
    /// - Parameter error: Enum representing the type of error that occurred.
    func handleWeatherFetchError(_ error: WeatherManagerError) {
        let errorMessage = error.userFriendlyAlertMessage

        print("WeatherViewController: Handling weather fetch error: \(error)")
        
        DispatchQueue.main.async {
            AlertUtility.showAlertWithRetry(on: self, title: "Oops!", message: errorMessage) {
                // Retry logic if last known coordinates are available
                if let latitude = self.lastKnownLatitude, let longitude = self.lastKnownLongitude {
                    self.weatherManager.fetchWeather(latitude: latitude, longitude: longitude)
                } else {
                    AlertUtility.showAlert(on: self, title: "Sorry", message: "We're unable to fetch your location and weather data. Please ensure location services are enabled and try again.")
                }
            }
        }
    }
    
    func animateWeatherImageView(with weather: WeatherType, and data: WeatherModel) {
        let config = WeatherVisualRepresentation.animationConfig(for: weather, isDay: data.isDay)
        print("Animating Weather Type: \(weather) with \(config.images.count) images over \(config.duration) seconds")
        startAnimation(images: config.images, duration: config.duration, weather: weather)
    }
    
    private func startAnimation(images: [UIImage], duration: Double, weather: WeatherType) {        
        print("Starting animation for \(weather). Total Images: \(images.count), Duration: \(duration)")
        weatherAnimationView.animationImages = images
        weatherAnimationView.animationDuration = duration
        weatherAnimationView.animationRepeatCount = 0
        weatherAnimationView.startAnimating()

        print("Animation should now be running for \(weather)")
    }
    
    func setupLoadingAnimation() {
        let imageNames = ["loading1", "loading2", "loading3", "loading4", "loading5"]
        let images = imageNames.compactMap { UIImage(named: $0) }
        loadingAnimation.animationImages = images
        loadingAnimation.animationDuration = 1.0
        loadingAnimation.animationRepeatCount = 0
        loadingAnimation.startAnimating()
    }
    
    // MARK: - Duck Methods
    
    func determineComfortLevel(feelsLikeTemperature: Double) -> ComfortLevel {
        if feelsLikeTemperature > Duck.hotThreshold {
            return .tooHot
        } else if feelsLikeTemperature < Duck.coldThreshold {
            return .tooCold
        } else {
            return .comfortable
        }
    }

    func updateDuckAnimation(feelsLikeTemperature: Double, isDaytime: Bool) {
        print("Updating duck animation with temperature: \(feelsLikeTemperature), daytime: \(isDaytime)")
        
        let comfortLevel = determineComfortLevel(feelsLikeTemperature: feelsLikeTemperature)
        let animationConfig = Duck.animationConfig(comfortLevel: comfortLevel, feelsLikeTemperature: feelsLikeTemperature, isDaytime: isDaytime)
        
        print("Animation images to be set: \(animationConfig.images.count)")
        print(animationConfig.images)
        duck.image = animationConfig.images[0]
        duck.animationImages = animationConfig.images
        duck.animationDuration = animationConfig.duration
        duck.animationRepeatCount = 0
        print("Starting duck animation...")
        duck.startAnimating()
    }
}

// MARK: - WeatherManagerDelegate

// This extension is kept in the same file as the WeatherViewController due to its contextual relevance.
extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        print("Weather data updated. Current Weather: \(weather.weatherType)")

        self.dailyForecast = weather.dailyForecast
        self.hourlyForecast = weather.hourlyForecast
        updateUI(with: weather)
    }
    
    func didFailToFetchWeatherWithError(error: WeatherManagerError) {
        print("Failed to fetch weather data with error: \(error)")

        handleWeatherFetchError(error)
    }
}



