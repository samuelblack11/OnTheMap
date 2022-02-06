//
//  LogoutResponse.swift
//  OnTheMap
//
//  Created by Sam Black on 2/5/22.
//

import Foundation

struct LogoutResponse: Codable {
    
    let session: LogoutSession
}

struct LogoutSession: Codable {
    let id: String
    let expiration: String
}
