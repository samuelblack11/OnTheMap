//
//  OnTheMapPreview.swift
//  OnTheMap
//
//  Created by Sam Black on 2/24/22.
//

import Foundation


import Foundation
import UIKit
import MapKit

/**
* This view controller demonstrates the objects involved in displaying pins on a map.
*
* The map is a MKMapView.
* The pins are represented by MKPointAnnotation instances.
*
* The view controller conforms to the MKMapViewDelegate so that it can receive a method
* invocation when a pin annotation is tapped. It accomplishes this using two delegate
* methods: one to put a small "info" button on the right side of each pin, and one to
* respond when the "info" button is tapped.
*/


class OnTheMapPreview: UIViewController, MKMapViewDelegate {
    var studentPin: StudentInformation!
        
    //MKMapView: This is the view that displays a map. In the sample code, it fills the entire view.
    //MKMapViewDelegate: the view controller conforms to this protocol to respond to pin taps.
    //MKPointAnnotation: The class that is used to hold the data for the pins.
    
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapToolBar: UIToolbar!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    
    //struct PostAttributes {
    var userLoc: String = ""
    var mapString: String = ""
    var mediaURL: String = "https://www.espn.com"
    var latitude: Float = 0.0
    var longitude: Float = 0.0
    var firstName: String = ""
    var lastName: String = ""


    @IBAction func clickLogout(_ sender: Any) {
        OTMClient.logout(completion: handleLogoutResponse(success:error:))
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
    }
    
    func handleLogoutResponse(success: Bool, error: Error?) {
        if success {
            self.dismiss(animated: true, completion: nil)
        } else {
                print("Logout Failed")
        }
    }
    
    // The "PinData" array is an array of dictionary objects that are similar to the JSON
    // data that you can download from parse.
    func showPins(_ pins: [StudentInformation]) {
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for pin in pins {
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let latitude = CLLocationDegrees(pin.latitude)
            let longitude = CLLocationDegrees(pin.longitude)
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let firstName = pin.firstName
            let lastName = pin.lastName
            let mediaURL = pin.mediaURL
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = ("\(firstName) \(lastName)")
            annotation.subtitle = mediaURL
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        // When the array is complete, we add the annotations to the map.
        //print("# of Keys in Annotations Dictionary: \(annotations.count)")
        self.mapView.addAnnotations(annotations)
    }
    
    @IBAction func pressDismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        print("Calling viewDidLoad")
        super.viewDidLoad()
        OTMClient.getPin(completion: handlePinsResponse(pins: error: ))
    }

    
    @IBAction func pressSubmit(_ sender: Any) {
   // https://stackoverflow.com/questions/24029917/convert-float-to-int-in-swift
        let lat:Double = Double(latitude)
        let long:Double = Double(longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        OTMClient.postPinForPreview(with: createStudentInstance(coordinate, url: mediaURL), completion: handlePostPreview(success:error:))
    }
    
    
    
    
    func handlePostPreview(success: Bool, error: Error?) {
        if success {
            print("no error in handlePostStudentResponse -----")
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            self.showFailure(title: "Unable to Post Location", message: "Unable to Post Location")
        }
    }
    
    func createStudentInstance(_ coordinate: CLLocationCoordinate2D, url: String) -> StudentInformation {
        // https://www.hackingwithswift.com/example-code/system/how-to-convert-dates-and-times-to-a-string-using-dateformatter
        let today = Date()
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        
        OTMClient.getUserData(completion: handleUserData(firstName:lastName:error:))

        let studentPin = StudentInformation(objectId: "", uniqueKey: OTMClient.Endpoints.Auth.uniqueKey, firstName: OTMClient.Endpoints.Auth.firstName, lastName: OTMClient.Endpoints.Auth.lastName, mapString: "mapString", mediaURL: url, latitude: coordinate.latitude, longitude: coordinate.longitude, createdAt: formatter1.string(from: today), updatedAt: formatter1.string(from: today))
        
        return studentPin
    }
    
    func handleUserData(firstName: String?, lastName: String?, error: Error?) {
        if error == nil {
            
            OTMClient.postPinToServer(firstName: firstName!, lastName: lastName!, mapString: self.mapString, mediaURL: self.mediaURL, latitude: self.latitude, longitude: self.longitude, completion: handlePostStudentResponse(success:error:))
            
         print("no error in handleUserData -----")
            //self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

            let mapVC = storyboard?.instantiateViewController(identifier: "OnTheMapViewController") as! OnTheMapViewController
            let previewVC = storyboard?.instantiateViewController(identifier: "OnTheMapPreview") as! OnTheMapPreview

            self.present(mapVC, animated: true, completion: nil)
            previewVC.dismiss(animated: true, completion: nil)

        } else {
            showFailure(title: "Not Possible to Get User Information", message: error?.localizedDescription ?? "")
        }
    }
    
    func handlePostStudentResponse(success: Bool, error: Error?) {
        if success {
            print("no error in handlePostStudentResponse -----")
        } else {
            showFailure(title: "Not Possible to Save Information", message: error?.localizedDescription ?? "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            searchForNewPins()
    }
    
    func showFailure(title: String, message: String) {
            // if no internet: Internet if Offline
            // if credentials were incorrect: check email/password
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            show(alertVC, sender: nil)
        }
    
    
    func searchForNewPins() {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = userLoc
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            
            guard let response = response else {
                return
            }
            
            let pin = MKPointAnnotation()
            pin.coordinate = response.mapItems[0].placemark.coordinate
            pin.title = response.mapItems[0].name
            //pin.url = response.mapItems[0].placemark.mediaUrl
            self.mapView.addAnnotation(pin)
            self.mapView.setCenter(pin.coordinate, animated: true)
            let region = MKCoordinateRegion(center: pin.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
    }
    }
    
    // MARK: - MKMapViewDelegate

    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    enum URLError: Error {
        case invalid
        case valid
    }
    
    //https://stackoverflow.com/questions/63101116/correct-way-to-handle-incorrect-url-when-opening
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Calling mapView")
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                
                print("---------------")
                print(toOpen)
                print("---------------")
                let url = URL(string: toOpen)!
                print(url)
                print("---------------")
                UIApplication.shared.open(url, completionHandler: { success in
                    if success {
                        print("opened")
                    } else {
                        print("failed")
                        self.showFailure(title: "Invalid URL", message: "Is there a valid URL for this pin?")
                    }
                })
                
                

            }
        }
    }
                                          
    
    func handlePinsResponse(pins: [StudentInformation], error: Error?) {
        if error == nil {
            if self.mapView.annotations.count > 0 {
                self.mapView.removeAnnotations(self.mapView.annotations)
            }
            Pins().pins = pins
            showPins(pins)
        } else {
            showFailure(title: "Unable to Get Pins", message: "Unable to Get Pins")
            print(error ?? "Error in handlePinsResponse")
        }
        }
    }
