//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Sam Black on 1/22/22.
//

import Foundation

class OTMClient {
    
    
    struct Auth {
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1/session"
        
        case login
        case createSessionId
        case logout
        case webAuth
        
        var stringValue: String {
            switch self {

            case .login:
                return Endpoints.base
            case .createSessionId:
                return Endpoints.base
            case .logout:
                return Endpoints.base
            case .webAuth:
                return Endpoints.base
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func createSessionId(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        print("func createSessionId called")
        let body = LoginRequest(username: username, password: password)
        taskForPOSTRequest(url: Endpoints.createSessionId.url, responseType: SessionResponse.self, body: body) { response, error in
            if let response = response {
                Auth.sessionId = response.session.sessionId
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }

    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        //request.httpBody = "{\"udacity\": {\"username\": \"\(body.username)\", \"password\": \"\(body.password)\"}}".data(using: .utf8)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Error in handleRequestTokenResponse here
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            
            guard let newData = newData else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
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
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        print("func login called")
        let body = LoginRequest(username: username, password: password)
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpBody = "{\"udacity\": {\"username\": \"\(body.username)\", \"password\": \"\(body.password)\"}}".data(using: .utf8)
        request.httpMethod = "POST"
        //request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Error in handleRequestTokenResponse here
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
        let range = 5..<data!.count
        let newData = data?.subdata(in: range) /* subset response data! */
        print(String(data: newData!, encoding: .utf8)!)
        }
    task.resume()
    }

    //https://knowledge.udacity.com/questions/764046
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        print("\(url)")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
            }
        }
        task.resume()
        return task
    }
}
    

