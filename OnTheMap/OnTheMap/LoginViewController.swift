//
//  ViewController.swift
//  OnTheMap
//
//  Created by Sam Black on 1/22/22.
//

import UIKit
import Network

class LoginViewController: UIViewController {

        @IBOutlet weak var emailTextField: UITextField!
        @IBOutlet weak var passwordTextField: UITextField!
        @IBOutlet weak var loginButton: UIButton!
        @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        let monitor = NWPathMonitor()
        var connected: Bool = true
    
 //  https://www.hackingwithswift.com/example-code/networking/how-to-check-for-internet-connectivity-using-nwpathmonitor
    func connectivity() -> Bool {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected")
                self.connected = true
            }
            else {
                self.connected = false
            }
        }
        return connected
    }
    
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            emailTextField.text = ""
            passwordTextField.text = ""
        }
        
        //https://knowledge.udacity.com/questions/310855
        @IBAction func loginTapped(_ sender: UIButton) {
            print("loginTapped Called")
            setLoggingIn(true)
            print("setLoggingIn worked....")
            print("Attempting login function now....")
            OTMClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLoginResponse(success:error:))
        }
        
    func handleLoginResponse(success: Bool, error: Error?) {
        print("trying handleLoginResponse....")
        if success {
            print("success in handleLoginResponse")
            OTMClient.createSessionId(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: handleSessionResponse(success:error:))
        } else {
            print("error in handleLoginResponse")
            showLoginFailure(title: "Login Failed", message: error?.localizedDescription ?? "")
        }
    }
    
    func handleSessionResponse(success: Bool, error: Error?) {
        print("trying handleSessionResponse....")
        setLoggingIn(false)
        if success {
            // Clear these text fields for when user logs out
            emailTextField.text = ""
            passwordTextField.text = ""
            performSegue(withIdentifier: "completeLogin", sender: self)
            print("handleSessionResponse SUCCESS!")
        }
        
        else if connectivity() {
            print("error in handleLoginResponse")
            // if bad credentials
            showLoginFailure(title: "Login Failed", message: "Invalid Login Credentials")
            }
        else {
            showLoginFailure(title: "Login Failed", message: "No Internet Connection")
        }
    }
     
        func setLoggingIn(_ loggingIn: Bool) {
            if loggingIn {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
            emailTextField.isEnabled = !loggingIn
            passwordTextField.isEnabled = !loggingIn
            loginButton.isEnabled = !loggingIn
        }
        
    func showLoginFailure(title: String, message: String) {
            // if no internet: Internet if Offline
            // if credentials were incorrect: check email/password
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            show(alertVC, sender: nil)
        }
    }

    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
