//
//  LogoutRequest.swift
//  OnTheMap
//
//  Created by Sam Black on 1/22/22.
//

import Foundation

struct LogoutRequest: Codable {
    let sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
    }
}
