//
//  LoginRequest.swift
//  OnTheMap
//
//  Created by Sam Black on 1/22/22.
//

import Foundation

struct LoginRequest: Codable {
    
    let username: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case password
    }
}
