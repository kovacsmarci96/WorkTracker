//
//  WorkRequest.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import Foundation

enum WorkError: Error {
    case nameError
    case networkError
}


struct WorkRequest {
    let resource: URL
    
    init(projectId: String, taskId: String, endpoint: String) {
        let resourceString = "http://192.168.1.72:45455/\(projectId)/task/\(taskId)/\(endpoint)"
        let resourceString2 = "http://192.168.1.72:45456/\(projectId)/task/\(taskId)/\(endpoint)"
        let urlString = resourceString2.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let resourceURL = URL(string: urlString!) else {
            fatalError()
        }
        
        self.resource = resourceURL
    }
    
    
    func addWork(_ token: String, _ work: WorkAdd, completion: @escaping(Result<WorkAdd, TaskError>) -> Void) {
        do {
            let tokenString = "Bearer " + token
            var urlRequest = URLRequest(url: resource)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue(tokenString, forHTTPHeaderField: "Authorization")
            urlRequest.httpBody = try JSONEncoder().encode(work)
            
            let session = URLSession.shared
            session.configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(token)"]
            
            let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        completion(.success(work))
                    }
                    if response.statusCode == 500 {
                        completion(.failure(.nameError))
                    }
                }
            }.resume()
        
        } catch {
            completion(.failure(.networkError))
        }
    }
    
    func getAllWork(_ token: String, completion: @escaping(Result<[Work], WorkError>) -> Void) {
        do {
            let tokenString = "Bearer " + token
            var urlRequest = URLRequest(url: resource)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue(tokenString, forHTTPHeaderField: "Authorization")
            
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                if let jsonData = data{
                    do{
                        let works = try JSONDecoder().decode([Work].self, from: jsonData)
                        completion(.success(works))
                    } catch {
                        completion(.failure(.networkError))
                    }
                }
            }.resume()
        }
    }
    
    func updateWork(_ token: String, _ workAdd: WorkAdd, completion: @escaping(Result<WorkAdd, WorkError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resource)
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.httpMethod = "PUT"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(workAdd)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        completion(.success(workAdd))
                    }
                }
            }.resume()
        
        } catch {
            completion(.failure(.networkError))
        }
    }
    
    func deleteWork(_ token:String, completion: @escaping(Result<Work, WorkError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resource)
            urlRequest.httpMethod = "DELETE"
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    print("Response: \(response)")
                }
            }.resume()
        } catch {
            completion(.failure(.networkError))
        }
    }
}
