//
//  ViewController.swift
//  OnTheMap
//
//  Created by Sam Black on 1/22/22.
//

import UIKit

class LoginViewController: UIViewController {

  //  override func viewDidLoad() {
   //     super.viewDidLoad()
   //     // Do any additional setup after loading the view.
    //}
            
        @IBOutlet weak var emailTextField: UITextField!
        @IBOutlet weak var passwordTextField: UITextField!
        @IBOutlet weak var loginButton: UIButton!
        @IBOutlet weak var loginViaWebsiteButton: UIButton!
        @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            emailTextField.text = ""
            passwordTextField.text = ""
        }
        
        //https://knowledge.udacity.com/questions/310855
        @IBAction func loginTapped(_ sender: UIButton) {
            setLoggingIn(true)
            OTMClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLoginResponse(success:error:))
        }
        
        @IBAction func loginViaWebsiteTapped() {
            setLoggingIn(true)
            OTMClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLoginResponse(success:error:))
        }
    
    func handleLoginResponse(success: Bool, error: Error?) {
        print("\(success)")
        if success {
            print("success in handleLoginResponse")
            OTMClient.createSessionId(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: handleSessionResponse(success:error:))
        } else {
            print("error in handleLoginResponse")
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func handleSessionResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        if success {
            performSegue(withIdentifier: "completeLogin", sender: nil)
        } else {
            print("error in handleLoginResponse")
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    
    
    
    
    
    
    
        
        func handleRequestTokenResponse(success: Bool, error: Error?) {
            print("trying....")
            print("Success: \(success)")
            if success {
                print("\(emailTextField.text)")
                print("\(passwordTextField.text)")
                OTMClient.login(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
            } else {
                print("error in handleRequestTokenResponse")
                showLoginFailure(message: error?.localizedDescription ?? "")
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
            loginViaWebsiteButton.isEnabled = !loggingIn
        }
        
        func showLoginFailure(message: String) {
            let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            show(alertVC, sender: nil)
        }

    }

    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }

