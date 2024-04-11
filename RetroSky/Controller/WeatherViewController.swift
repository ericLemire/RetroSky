//
//  ViewController.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/08/30.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    // MARK: - UI Outlets
    // Outlets connecting the storyboard elements to the view controller for UI updates.
    
    // Displays the current loading state and weather animation.
    @IBOutlet private weak var loadingView: UIView!
    @IBOutlet private weak var loadingAnimation: UIImageView!
    
    // Displays current weather information.
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var temperatureNotation: UILabel!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var degreeSymbol: UILabel!
    @IBOutlet private weak var weatherAnimationView: UIImageView!
    @IBOutlet private weak var feelsLikeLabel: UILabel!
    @IBOutlet private weak var feelsLikeTemperatureLabel: UILabel!
    @IBOutlet private weak var duck: UIImageView!
    
    // Displays forecast data.
    @IBOutlet private weak var dailyForecastLabel: UILabel!
    @IBOutlet private weak var dailyForecastHeader: UILabel!
    @IBOutlet weak var hourlyForecastCollectionView: UICollectionView!
    @IBOutlet weak var dailyForecastCollectionView: UICollectionView!
    
    // MARK: - Core Properties
    // Flags and formatters for managing state and display formatting.
    private var isAlreadyLaunched = false
    let temperatureFormatter = TemperatureFormatter()
        
    // Manages weather data fetching and updates.
    var weatherManager: WeatherManager!
    
    // MARK: - Data Models
    // Stores weather forecast data for display in the UI.
    var hourlyForecast: [HourForecast] = []
    var dailyForecast: [DayForecast] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setupLoadingAnimation()

        weatherManager.delegate = self
        weatherManager.uiDelegate = self
        
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
        weatherManager?.refreshWeatherData()
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
            AlertUtility.showAlert(on: self, title: "Oops!", message: errorMessage)
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

extension WeatherViewController: WeatherManagerUIDelegate {
    func showLocationAccessDeniedAlert() {
        DispatchQueue.main.async {
            AlertUtility.showAlert(on: self,
                                   title: AlertMessages.accessDeniedTitle,
                                   message: AlertMessages.accessDeniedMessage,
                                   actions: [
                                    UIAlertAction(title: "Go to Settings", style: .default, handler: self.goToSettings),
                                    UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                   ]
            )
        }
    }
                                   
    func showLocationAccessRestrictedAlert() {
        DispatchQueue.main.async {
            AlertUtility.showAlert(on: self,
                                   title: AlertMessages.accessRestrictedTitle,
                                   message: AlertMessages.accessRestrictedMessage,
                                   actions: [
                                    UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                   ]
            )
        }
    }
    
    private func goToSettings(action: UIAlertAction) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
               


                                
