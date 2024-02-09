//
//  DuckAnimation.swift
//  RetroSky
//
//  Created by Eric Lemire on 2024/01/31.
//

import UIKit

enum ComfortLevel {
    case tooHot
    case comfortable
    case tooCold
}

struct Duck {
    static let hotThreshold = 25.0
    static let coldThreshold = 5.0

    static func animationConfig(comfortLevel: ComfortLevel, feelsLikeTemperature: Double, isDaytime: Bool) -> (images: [UIImage], duration: Double) {
        var imageNames = [String]()

        
        switch comfortLevel {
        case .comfortable:
            imageNames = isDaytime ? ["duck", "duck", "duck", "duck", "duck", "duckQuack"] : ["nightNormal"]
        case .tooCold:
            imageNames = isDaytime ? ["tuque", "tuque", "tuque", "tuque", "tuque", "tuqueQuack"] : ["nightTuque"]
        case .tooHot:
            imageNames = isDaytime ? ["sunglasses", "sunglasses", "sunglasses", "sunglasses", "sunglasses", "sunglassesQuack"] : ["nightSunglasses"]
        }

        let images = imageNames.compactMap { UIImage(named: $0) }
        let duration = Double(imageNames.count) * 0.3
        
        return (images: images, duration: duration)
    }
}
