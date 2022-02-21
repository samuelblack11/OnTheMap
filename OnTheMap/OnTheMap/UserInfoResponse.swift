//
//  UserInfoResponse.swift
//  OnTheMap
//
//  Created by Sam Black on 2/20/22.
//

import Foundation
struct UserInfoResponse: Codable {
    let firstName: String
    let lastName: String

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
