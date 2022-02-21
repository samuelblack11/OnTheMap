//
//  PostPinViewController.swift
//  OnTheMap
//
//  Created by Sam Black on 2/6/22.
//

import Foundation
import UIKit
import CoreLocation

//protocol FinalizeCreatePinVCDelegate: AnyObject {
//    func dismissFinalizeCreatePinVC()
//}

class PostPinViewController: UIViewController, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    
    @IBOutlet weak var addressBox: UITextField!
    @IBOutlet weak var urlBox: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var studentPins = [StudentInformation]()
    var studentPin: StudentInformation!
    //var delegate: FinalizeCreatePinVCDelegate?



    
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
    
    
    func showFailure(title: String, message: String) {
            // if no internet: Internet if Offline
            // if credentials were incorrect: check email/password
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            show(alertVC, sender: nil)
        }
    
    // https://github.com/jgerardo214/On-The-Map/blob/main/On%20the%20Map/Controller/InformationPostingVC.swift
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        print("check 1")
        if addressBox.text!.isEmpty {
            print("addressbox empty")
            let alert = UIAlertController(title: "Please Enter a Location", message: "No Location was entered", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK, I'll Enter a Location!", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            print("else")
            spinActivityIndicator(true)
            print("else 2")
                geocoder.geocodeAddressString(addressBox.text ?? "") { placemarks, error in
                    self.processAddress(withPlacemarks: placemarks, error: error)
                }
            print("else 3")
            }
        }

    

   
    func processAddress(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        print("processAddress 1")
        if error != nil {
            spinActivityIndicator(false)
            print(error ?? "Can't Find Location")
            showFailure(title: "Geocoding Failed", message: "Geocoding Failed")
        }
        else {
            print ("else 1")
            if let placemarks = placemarks, placemarks.count > 0 {
                let location = (placemarks.first?.location)! as CLLocation
                let coordinate = location.coordinate
                self.latitude = Float(coordinate.latitude)
                self.longitude = Float(coordinate.longitude)
                spinActivityIndicator(false)
                let submitVC = storyboard?.instantiateViewController(identifier: "OnTheMapViewController") as! OnTheMapViewController
                submitVC.userLoc = addressBox.text
                submitVC.mediaURL = urlBox.text
                submitVC.latitude = self.latitude
                submitVC.longitude = self.longitude
                self.present(submitVC, animated: true, completion: nil)
                print("process address Success")
                
                // Post the Pin
                OTMClient.postPin(with: createStudentInstance(coordinate), completion: { (success, error) in
                if error != nil {
                    self.showFailure(title: "Unable to Post Location", message: "Unable to Post Location")
                    }
                DispatchQueue.main.async {
                    //self.delegate?.dismissFinalizeCreatePinVC()
                    print("No error in Post")
                    }
                })            }
        }
    }
    
    func createStudentInstance(_ coordinate: CLLocationCoordinate2D) -> StudentInformation {
        // https://www.hackingwithswift.com/example-code/system/how-to-convert-dates-and-times-to-a-string-using-dateformatter
        let today = Date()
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        print(formatter1.string(from: today))
        print("Trying to get user data......")

        
        OTMClient.getUserData(completion: handleUserData(firstName:lastName:error:))
        print("----------")
        print("Got user data")

        let studentPin = StudentInformation(objectId: "", uniqueKey: OTMClient.Endpoints.Auth.uniqueKey, firstName: UserInfoResponse.firstName, lastName: "testtesttest", mapString: "mapString", mediaURL: urlBox.text, latitude: coordinate.latitude, longitude: coordinate.longitude, createdAt: formatter1.string(from: today), updatedAt: formatter1.string(from: today))

        return studentPin
    }
    
    
    func handleUserData(firstName: String?, lastName: String?, error: Error?) {
        if error == nil {
            ////////////////////////////////////
            
            print("no error in handleUserData")
        } else {
            showFailure(title: "Not Possible to Get User Information", message: error?.localizedDescription ?? "")
        }
    }
    
    func handlePostStudentResponse(success: Bool, error: Error?) {
        if success {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            showFailure(title: "Not Possible to Save Information", message: error?.localizedDescription ?? "")
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
