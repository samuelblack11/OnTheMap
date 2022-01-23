//
//  LoginButton.swift
//  OnTheMap
//
//  Created by Sam Black on 1/22/22.
//

import Foundation

import UIKit

class LoginButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 5
        tintColor = UIColor.white
        backgroundColor = UIColor.black
    }
    
}
