//
//  WeatherViewController+CollectionView.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/22.
//

import UIKit

extension WeatherViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    static let dailyCellIdentifier = "DailyCell"
    static let hourlyCellIdentifier = "HourlyCell"

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == dailyForecastCollectionView {
            return dailyForecast.count
        } else if collectionView == hourlyForecastCollectionView {
            return hourlyForecast.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == dailyForecastCollectionView {
            return configureDailyForecastCell(at: indexPath, with: collectionView)
        } else if collectionView == hourlyForecastCollectionView {
            return configureHourlyForecastCell(at: indexPath, with: collectionView)
        }
        print("Failed to dequeue and cast the cell.")
        return UICollectionViewCell()
    }

    private func configureDailyForecastCell(at indexPath: IndexPath, with collectionView: UICollectionView) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherViewController.dailyCellIdentifier, for: indexPath) as? DailyForecastCell {
            cell.configure(with: dailyForecast[indexPath.row], formatter: temperatureFormatter)
            return cell
        }
        print("Failed to dequeue and cast the cell.")
        return UICollectionViewCell()
    }

    private func configureHourlyForecastCell(at indexPath: IndexPath, with collectionView: UICollectionView) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherViewController.hourlyCellIdentifier, for: indexPath) as? HourlyForecastCell {
            cell.configure(with: hourlyForecast[indexPath.row], formatter: temperatureFormatter)
            return cell
        }
        print("Failed to dequeue and cast the cell.")
        return UICollectionViewCell()
    }
}

