//
//  WeatherNetworkService.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/20.
//

import Foundation

/// Protocol defining the basic requirements for a network service.
protocol NetworkServiceProtocol {
    /// Performs a network request to the specified URL string and returns the result asynchronously.
    /// - Parameters:
    ///   - urlString: The URL string where the request is made.
    ///   - completion: A completion handler called with the data and error returned from the request.
    func performRequest(with urlString: String, completion: @escaping (Data?, Error?) -> Void)
}

/// A service responsible for performing network requests and fetching weather data.
struct WeatherNetworkService: NetworkServiceProtocol {
    
    /// Performs a network request to the specified URL string and returns the result asynchronously.
    /// If the URL is invalid, it completes with an error. Otherwise, it fetches the data from the network.
    /// - Parameters:
    ///   - urlString: The URL string where the request is made.
    ///   - completion: A completion handler called with the data and error returned from the request.
    func performRequest(with urlString: String, completion: @escaping (Data?, Error?) -> Void) {
        // Attempt to create a URL from the string.
        if let url = URL(string: urlString) {
            print("NetworkService: Requesting data from URL: \(url)")
            
            // Create a default URL session configuration.
            let session = URLSession(configuration: .default)
            
            // Create a data task to retrieve the contents of the specified URL.
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    // Log and return an error if the request fails.
                    print("NetworkService: Error fetching data: \(error.localizedDescription)")
                } else {
                    // Log the successful data retrieval.
                    print("NetworkService: Data fetched successfully. Data length: \(String(describing: data?.count))")
                }
                // Complete with the data and any error (nil if no error).
                completion(data, error)
            }
            // Start the network request task.
            task.resume()
        } else {
            // Log and return an error if the URL string is invalid.
            print("NetworkService: Invalid URL: \(urlString)")
            completion(nil, NSError(domain: "Invalid URL", code: 1001, userInfo: nil))
        }
    }
}


