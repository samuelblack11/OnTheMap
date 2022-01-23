//
//  SessionResponse.swift
//  OnTheMap
//
//  Created by Sam Black on 1/22/22.
//

import Foundation

struct SessionResponse: Codable {
    
    let success: Bool
    let sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case sessionId = "session_id"
    }
    
}
