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

    
    @IBOutlet var pinTableView: UITableView!
    
    //var results = [StudentInformation]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func viewDidLoad(_ animated: Bool) {
        print("PinTableViewController viewDIDLOAD")
        super.viewDidLoad()
            OTMClient.getPin(completion: handlePinResponse(pins: error:))
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        }
    
    func handlePinResponse(pins: [StudentInformation], error: Error?) {
            print("Starting handlePinResponse.....")
            if error == nil {
            Pins().pins = pins
            print("appDelegate.pins = pins")
            self.tableView.reloadData()
        } else {
            print("handlePinResponse failed")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Pins().pins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinTableViewCell") as! PinTableViewCell
        
        let pin = Pins().pins[(indexPath as NSIndexPath).row]
        //cell.name?.text = "\(pin.firstName ?? "Joe") \(pin.lastName ?? "Shmo")"
        cell.name?.text = pin.lastName
        cell.mediaURL.text = pin.mediaURL ?? "https://google.com"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableCell = tableView.cellForRow(at: indexPath) as! PinTableViewCell
        let app = UIApplication.shared
        if let toOpen = tableCell.mediaURL?.text! {
            app.open(URL(string: toOpen)!)
        }
        else{
            showFailure(title: "URL Invalid", message: "URL Invalid")
        }
        
        func showFailure(title: String, message: String) {
                let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                show(alertVC, sender: nil)
            }
        
    }
    
    @IBAction func clickLogout(_ sender: Any) {
        OTMClient.logout(completion: handleLogoutResponse(success:error:))
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleLogoutResponse(success: Bool, error: Error?) {
        if success {
            self.dismiss(animated: true, completion: nil)
        } else {
                print("Logout Failed")
        }
    }
    
}
