//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Sam Black on 1/22/22.
//

import Foundation
import UIKit

class OTMClient {
    
    

    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1/"
        
        case login
        case createSessionId
        case logout
        case webAuth
        case studentLoc
        case getUserData
        
        struct Auth {
            static var requestToken = ""
            static var sessionId = ""
            static var uniqueKey = ""
            static var firstName = ""
            static var lastName = ""
            //static var mediaURL = ""
        }
        
        var stringValue: String {
            switch self {

            case .login:
                return Endpoints.base + "session"
            case .createSessionId:
                return Endpoints.base + "session"
            case .logout:
                return Endpoints.base + "session"
            case .webAuth:
                return Endpoints.base + "session"
            case .getUserData:
                return Endpoints.base + "/users/\(Auth.uniqueKey)"
            case .studentLoc:
                return Endpoints.base + "StudentLocation?limit=100&order=-updatedAt"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    class func createSessionId(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        print("func createSessionId called")
        let body = LoginRequest(username: username, password: password)
        taskForPOSTRequest(username: body.username, password: body.password, url: Endpoints.createSessionId.url, responseType: SessionResponse.self, body: body) { response, error in
            if let response = response {
                Endpoints.Auth.sessionId = response.session.sessionId
                Endpoints.Auth.uniqueKey = response.account.key
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }

    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(username: String, password: String, url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        print("trying taskForPOSTRequest....")
        let body = LoginRequest(username: username, password: password)
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpBody = "{\"udacity\": {\"username\": \"\(body.username)\", \"password\": \"\(body.password)\"}}".data(using: .utf8)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("taskForPOSTRequest checkpoint")

        // Error in handleRequestTokenResponse here
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)

            guard let newData = newData else {
                DispatchQueue.main.async {
                    completion(nil, error)
                    print("newData is nil")
                }
                print("newData not nil")
                return

            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }
            catch {
                do {
                    let errorResponse = try decoder.decode(OTMResponse.self, from: newData) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
    task.resume()
    }
    
    //https://knowledge.udacity.com/questions/71759
    //https://knowledge.udacity.com/questions/270411
    //https://knowledge.udacity.com/questions/175154
    // https://knowledge.udacity.com/questions/311555
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        print("func login called")
        let body = LoginRequest(username: username, password: password)
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpBody = "{\"udacity\": {\"username\": \"\(body.username)\", \"password\": \"\(body.password)\"}}".data(using: .utf8)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Error in handleRequestTokenResponse here
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("Printing RESPONSE: \(response)")
            if error != nil { // Handle error…
                completion(false, error)
                return
            }
        do {
        let range = 5..<data!.count
        let newData = data?.subdata(in: range) /* subset response data! */
        print(String(data: newData!, encoding: .utf8)!)
        completion(true, nil)
        //Endpoints.Auth.uniqueKey = response.account.key
        print("login func complete, true")
            }
        }
    task.resume()
    }
    
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, removeFirstCharacters: Bool, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
            let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                var newData = data
                if removeFirstCharacters {
                    let range = 5..<data.count
                    newData = newData.subdata(in: range) /* subset response data! */
                }
                let decoder = JSONDecoder()
                do {
                    let responseObject = try decoder.decode(ResponseType.self, from: newData)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
            task.resume()
            
            return task
        }
    
    
    class func postReq<RequestType: Encodable, ResponseType: Decodable>(url: URL, trim: Bool, body: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONEncoder().encode(body)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    DispatchQueue.main.async {completion(nil, error)}
                        return
                    }
                var newData = data
                if trim {
                    let range = 5..<data.count
                    newData = newData.subdata(in: range) /* subset response data! */
                }
                let decoder = JSONDecoder()
                
                do {
                    let responseObject = try decoder.decode(ResponseType.self, from: newData)
                    DispatchQueue.main.async {
                        completion((responseObject ), nil)
                    }
                } catch {
                    completion(nil, error)
                }
            }
        task.resume()
        //return task
    }
    
    class func taskForDELETERequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (Bool, Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            let range = 5..<data.count
            let newData = data.subdata(in: range)
            let decoder = JSONDecoder()
            do {
                _ = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
        return task
    }
    

    
    // https://github.com/Casben/OnTheMap/blob/master/OnTheMap/Networking/NetworkManager.swift
    class func postPin(with student: StudentInformation, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = "{\"uniqueKey\": \"12345\", \"firstName\": \"\(student.firstName!)\", \"lastName\": \"\(student.lastName!)\",\"mapString\": \"\(student.mapString!)\", \"mediaURL\": \"\(student.mediaURL!)\",\"latitude\": \(student.latitude!), \"longitude\": \(student.longitude!)}".data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
          if error != nil { // Handle error…
              return
          }
          print(String(data: data!, encoding: .utf8)!)
        }
        task.resume()
    }
    
    class func getUserData(completion: @escaping (Bool, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getUserData.url, removeFirstCharacters: true, response: UserInfoResponse.self, completion: { (response, error) in
            if let response = response {
                OTMClient.Endpoints.Auth.firstName = response.firstName
                OTMClient.Endpoints.Auth.lastName = response.lastName
                print("getUserData -------")
                print(OTMClient.Endpoints.Auth.firstName)
                print(OTMClient.Endpoints.Auth.lastName)
                completion(true, nil)

            } else {
                completion(false, error)
            }
        })
    }
    

    // may go back to throws before curly bracket
    class func getPin(completion: @escaping ([StudentInformation], Error?) -> Void)  {
        let _ = taskForGETRequest(url: Endpoints.studentLoc.url, removeFirstCharacters: false, response: PinResponse.self, completion: { (response, error) in
            if let response = response {
                completion(response.results, nil)
            } else {
                
                completion([], error)
            }
        })
    }
    
    class func logout(completion: @escaping (Bool, Error?) -> Void) {
        let _ = taskForDELETERequest(url: Endpoints.logout.url, response: LogoutResponse.self) { (response, error) in
            completion(response, error)
            }
        }
    }
    

