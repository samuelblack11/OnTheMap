//
//  PostPinViewController.swift
//  OnTheMap
//
//  Created by Sam Black on 2/6/22.
//

import Foundation
import UIKit
import CoreLocation

class PostPinViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    
    @IBOutlet weak var addressBox: UITextField!
    @IBOutlet weak var urlBox: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
       var geocoder = CLGeocoder()
       var latitude: Float = 0.0
       var longitude: Float = 0.0
       var keyboardIsVisible = false
       var mediaUrl: String = ""
       var pinnedLocation: String!
       
       override func viewDidLoad() {
           addressBox.delegate = self
           urlBox.delegate = self
           self.activityIndicator.isHidden = true
           self.activityIndicator.hidesWhenStopped = true
       }
       
       override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           subscribeToKeyboardNotifications()
       }
       
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // https://github.com/jgerardo214/On-The-Map/blob/main/On%20the%20Map/Controller/InformationPostingVC.swift
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        print("check 1")
        if addressBox.text!.isEmpty {
            let alert = UIAlertController(title: "Please Enter a Location", message: "No Location was entered", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK, I'll Enter a Location!", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            print("check 2**")
            spinActivityIndicator(true)
            geocoder.geocodeAddressString(addressBox.text ?? "") { placemarks, error in
                self.processAddress(withPlacemarks: placemarks, error: error)
                //            self.dismiss(animated: true, completion: nil)
            }
        }
    }

   
    func processAddress(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if error != nil {
            spinActivityIndicator(false)
            print(error ?? "Can't Find Location")
        } else {
            if let placemarks = placemarks, placemarks.count > 0 {
                let location = (placemarks.first?.location)! as CLLocation
                let coordinate = location.coordinate
                self.latitude = Float(coordinate.latitude)
                self.longitude = Float(coordinate.longitude)
                //self.mediaUrl = urlBox.text
                spinActivityIndicator(false)
                let submitVC = storyboard?.instantiateViewController(identifier: "OnTheMapViewController") as! OnTheMapViewController
                submitVC.userLoc = addressBox.text
                submitVC.mediaURL = urlBox.text
                submitVC.latitude = self.latitude
                submitVC.longitude = self.longitude
                self.present(submitVC, animated: true, completion: nil)
                print("process address Success")
            } else {
                spinActivityIndicator(false)
                print(error ?? "Location Must be More Specific")
            }
        }
    }
    
    func spinActivityIndicator(_ searchingForAddress: Bool) {
        if searchingForAddress {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    
    // MARK: Keyboard Functions
    @objc func keyboardWillShow(_ notification:Notification) {
        if !keyboardIsVisible {
            if addressBox.isEditing {
                view.frame.origin.y -= getKeyboardHeight(notification) - 50 - urlBox.frame.height
            } else if urlBox.isEditing {
                view.frame.origin.y -= getKeyboardHeight(notification) - 50
            }
            keyboardIsVisible = true
        }
    }
    
    // Function called when screen must be moved down
    @objc func keyboardWillHide(_ notification:Notification) {
        if keyboardIsVisible {
            view.frame.origin.y = 0
            keyboardIsVisible = false
        }
    }
    
    // Get keyboard size for move the screen
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
