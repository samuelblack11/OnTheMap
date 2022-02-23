//
//  PinTableViewController.swift
//  OnTheMap
//
//  Created by Sam Black on 2/5/22.
//

import Foundation
import UIKit

class PinTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mediaURL: UILabel!
}

class PinTableViewController: UITableViewController {
    var selectedName: String = "PinTableViewController"
    
    // https://knowledge.udacity.com/questions/188630
    var studentPins = [StudentInformation]()

    @IBOutlet var pinTableView: UITableView!
    
    func viewDidLoad(_ animated: Bool) {
        print("PinTableViewController viewDIDLOAD")
        super.viewDidLoad()
        pinTableView.delegate = self
        pinTableView.dataSource = self
        OTMClient.getPin(completion: handlePinResponse(pins: error:))
        OTMClient.getPin(completion: handlePinResponse(pins: error:))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("PinTableViewController viewWillAppear called")
        super.viewWillAppear(animated)
        OTMClient.getPin(completion: handlePinResponse(pins: error:))
        }
    
    func handlePinResponse(pins: [StudentInformation], error: Error?) {
            print("Starting handlePinResponse.....")
            if error == nil {
                self.studentPins = pins
                print("\(pins.count)")
                self.tableView.reloadData()
                self.pinTableView.reloadData()
        } else {
            showFailure(title: "Unable to Get Pins", message: "Unable to Get Pins")
        }
    }
    
    
    @IBAction func pressMapButton(_ sender: Any) {
        performSegue(withIdentifier: "tableToMap", sender: nil)

    }
    
    @IBAction func pressPinButton(_ sender: Any) {
        performSegue(withIdentifier: "tableToPost", sender: nil)

    }
    
    
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberofRowsInSection: \(studentPins.count)")
        return studentPins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinTableViewCell") as! PinTableViewCell
        let pin = studentPins[(indexPath as NSIndexPath).row]
        cell.name?.text = "\(pin.firstName ?? "NoFirstName") \(pin.lastName ?? "NoLastName")"
        //cell.name?.text = pin.lastName
        cell.mediaURL.text = pin.mediaURL
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableCell = tableView.cellForRow(at: indexPath) as! PinTableViewCell
        if let webAddress = tableCell.mediaURL?.text! {
            if let url = URL(string: webAddress) {
                UIApplication.shared.open(url)
            }
            else {
                self.showFailure(title: "Invalid URL", message: "Is there a valid URL for this pin?")
            }
        }
    }
            
            
        func showFailure(title: String, message: String) {
                let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                show(alertVC, sender: nil)
            }
    
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

}
