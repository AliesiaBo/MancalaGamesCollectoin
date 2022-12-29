//
//  AlertsRealisation.swift
//  Kalah
//
//  Created by Aliesia Borzik on 12.09.2022.
//

import UIKit

extension UIViewController {
    
    func showInfoAlert(title: String, message: String, titleAction: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: titleAction, style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    ///Function that show action alert with two options: YES or NO
    func showActionAlert(title: String, message: String, doAction1: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "No", style: .default, handler: nil)
        let action2 = UIAlertAction(title: "Yes", style: .default, handler: doAction1)
        alert.addAction(action2)
        alert.addAction(action1)
        self.present(alert, animated: true, completion: nil)
    }
    ///Complex function that show action alert with three options: NO (do nothing), YES1 (do something), YES2 (do something else)
    func showTwoOptionsAlert(headTitle: String, message: String, noActionTitle: String, action1Title: String, action2Title: String, doAction1: @escaping (UIAlertAction) -> Void, doAction2: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: headTitle, message: message, preferredStyle: .alert)
        let action0 = UIAlertAction(title: noActionTitle, style: .default, handler: nil)
        let action1 = UIAlertAction(title: action1Title, style: .default, handler: doAction1)
        let action2 = UIAlertAction(title: action2Title, style: .default, handler: doAction2)
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action0)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(){
        showInfoAlert(title: K.ErrorMessage.e2, message: "", titleAction: "Ok")
    }
    
}
