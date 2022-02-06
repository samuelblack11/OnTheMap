//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Sam Black on 2/5/22.
//


import Foundation
import MapKit

// https://knowledge.udacity.com/questions/394507

struct StudentInformation: Codable, Equatable {
            
        let objectId: String?
        let uniqueKey: String?
        var firstName: String?
        let lastName: String?
        let mapString: String?
        let mediaURL: String?
        let latitude: Double
        let longitude: Double
        let createdAt: String?
        let updatedAt: String?
    
    
    
    
    enum CodingKeys: String, CodingKey {
        case objectId = "objectId"
        case uniqueKey = "uniqueKey"
        case firstName = "firstNameTwo"
        case lastName = "lastName"
        case mapString = "mapString"
        case mediaURL = "mediaURL"
        case latitude = "latitude"
        case longitude = "longitude"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
    
    
    }
