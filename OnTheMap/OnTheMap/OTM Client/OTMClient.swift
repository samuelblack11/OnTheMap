//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Sam Black on 1/22/22.
//

import Foundation

class OTMClient {
    
    static let apiKey = "AegonTar0919!"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1/session"
        static let apiKeyParam = "?api_key=\(OTMClient.apiKey)"
        
        case getRequestToken
        case login
        case createSessionId
        case logout
        case webAuth
        case search(String)
        
        var stringValue: String {
            switch self {

            case .getRequestToken:
                return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
            case .login:
                return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
            case .createSessionId:
                return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
            case .logout:
                return Endpoints.base + "/authentication/session" + Endpoints.apiKeyParam
            case .webAuth:
                return "https://www.themoviedb.org/authenticate/\(Auth.requestToken)?redirect_to=themoviemanager:authenticate"
            case .search(let query):
                return Endpoints.base + "/search/movie" + Endpoints.apiKeyParam + "&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func createSessionId(completion: @escaping (Bool, Error?) -> Void) {
        print("func createSessionId called")
        let body = PostSession(requestToken: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.createSessionId.url, responseType: SessionResponse.self, body: body) { response, error in
            if let response = response {
                Auth.sessionId = response.session.sessionId
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }

    //https://knowledge.udacity.com/questions/71759
    //https://knowledge.udacity.com/questions/270411
    //https://knowledge.udacity.com/questions/175154
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        print("func login called")
        let body = LoginRequest(username: username, password: password)
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(body.username)\", \"password\": \"\(body.password)\"}}".data(using: .utf8)
        print("-------------------")
        //request.httpBody = try! JSONEncoder().encode(body)
        let session = URLSession.shared
        print("checkpoint 1")
        // Error in handleRequestTokenResponse here
        print("DataTask:")
        let task = session.dataTask(with: request) { data, response, error in

          if error != nil { // Handle error…
              return
          }
        //print(task.data)
          print("checkpoint 2")
          let range = 5..<data!.count
          let newData = data?.subdata(in: range) /* subset response data! */
          print("checkpoint 3")
          print(String(data: newData!, encoding: .utf8)!)
          print("------------")
          print("checkpoint 4")
        }
        print("Task Parameter Values:")
        //print(task.data)
        print(task.response)
        print(task.error)

        task.resume()
        print("checkpoint 5")
    }
    
    
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getRequestToken.url, responseType: RequestTokenResponse.self) { response, error in
            if let response = response {
                Auth.requestToken = response.requestToken
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
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
                do {
                    let errorResponse = try decoder.decode(OTMResponse.self, from: data) as Error
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
        
        return task
    }
    
    
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
                do {
                    let errorResponse = try decoder.decode(OTMResponse.self, from: data) as Error
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
    
}
    

