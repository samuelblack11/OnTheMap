//
//  SessionResponse.swift
//  OnTheMap
//
//  Created by Sam Black on 1/22/22.
//

import Foundation

struct SessionResponse: Codable {
    
    let account: account
    let session: session

    
    struct account: Codable {
        let registered: Bool
        let key: String
        
        enum CodingKeys: String, CodingKey {
            case registered = "registered"
            case key = "key"
        }
        
    }
    struct session: Codable {
        let sessionId: String
        let expiration: String
        
        enum CodingKeys: String, CodingKey {
            case sessionId = "id"
            case expiration = "expiration"
        }
    }
    
}
