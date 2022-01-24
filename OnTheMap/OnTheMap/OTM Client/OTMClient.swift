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
        print("----------------------")
        taskForPOSTRequest(username: body.username, password: body.password, url: Endpoints.createSessionId.url, responseType: SessionResponse.self, body: body) { response, error in
            if let response = response {
                Auth.sessionId = response.session.sessionId
                print("createSessionId completion true")
                completion(true, nil)
            } else {
                completion(false, nil)
                print("createSessionId completion false")
            }
        }
    }

    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(username: String, password: String, url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        print("trying taskForPOSTRequest....")
        let body = LoginRequest(username: username, password: password)
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpBody = "{\"udacity\": {\"username\": \"\(body.username)\", \"password\": \"\(body.password)\"}}".data(using: .utf8)
        //request.httpBody = "{\"udacity\": {\"username\": \"\(username)", \"\(RequestType.password)": \"********\"}}".data(using: .utf8)
        
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("taskForPOSTRequest checkpoint")

        // Error in handleRequestTokenResponse here
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            print("taskForPOSTRequest checkpoint 2")

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
                print("taskForPOSTRequest checkpoint 3")
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                print("taskForPOSTRequest checkpoint 4")
                DispatchQueue.main.async {
                    
                    completion(responseObject, nil)
                    print("taskForPOSTRequest checkpoint 5")
                }
            }
            catch {
                do {
                    print("taskForPOSTRequest checkpoint 6")
                    let errorResponse = try decoder.decode(OTMResponse.self, from: newData) as Error
                    DispatchQueue.main.async {
                        print("taskForPOSTRequest checkpoint 7")
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("taskForPOSTRequest checkpoint 8")
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
        //request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Error in handleRequestTokenResponse here
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                completion(false, error)
                return
            }
        do {
        let range = 5..<data!.count
        let newData = data?.subdata(in: range) /* subset response data! */
        print(String(data: newData!, encoding: .utf8)!)
        completion(true, nil)
        print("login func complete, true")
        }
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
            print(("Response Type: \(ResponseType.self)"))
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
    

