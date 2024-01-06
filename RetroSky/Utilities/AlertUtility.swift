//
//  AlertUtility.swift
//  RetroSky
//
//  Created by Eric Lemire on 2023/09/21.
//

import UIKit

/// A utility struct for presenting common alerts in a UIViewController.
struct AlertUtility {
    
    /// Presents an alert with a customizable title, message, and actions on the specified view controller.
    /// - Parameters:
    ///   - viewController: The UIViewController on which the alert should be presented.
    ///   - title: The title of the alert.
    ///   - message: The message body of the alert.
    ///   - actions: An array of UIAlertActions to include in the alert. Defaults to a single "OK" action.
    static func showAlert(on viewController: UIViewController,
                          title: String,
                          message: String,
                          actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default, handler: nil)]) {
        // Initialize an alert controller with the provided title and message.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add each action from the actions array to the alert.
        for action in actions {
            alert.addAction(action)
        }
        
        // Present the alert on the specified view controller.
        viewController.present(alert, animated: true, completion: nil)
    }
    
    /// Presents an alert with a "Retry" and "Cancel" option on the specified view controller.
    /// - Parameters:
    ///   - viewController: The UIViewController on which the alert should be presented.
    ///   - title: The title of the alert.
    ///   - message: The message body of the alert.
    ///   - retryAction: A closure that gets executed when the "Retry" action is selected.
    static func showAlertWithRetry(on viewController: UIViewController, title: String, message: String, retryAction: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
            retryAction() }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        viewController.present(alert, animated: true)
    }
}

