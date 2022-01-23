//
//  PostSession.swift
//  OnTheMap
//
//  Created by Sam Black on 1/22/22.
//

import Foundation

struct PostSession: Codable {
    
    let requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case requestToken = "request_token"
    }
    
}
