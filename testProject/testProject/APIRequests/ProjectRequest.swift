//
//  ProjectRequest.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import Foundation

enum ProjectError: Error {
    case networkError
    case otherError
}

struct ProjectRequest {
    let resource: URL
    
    init(endpoint: String) {
        let resourceString = "http://192.168.1.72:45455/project/\(endpoint)"
        let resourceString2 = "http://192.168.1.72:45456/project/\(endpoint)"
        let urlString = resourceString2.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let resourceURL = URL(string: urlString!) else {
            fatalError()
        }
        
        self.resource = resourceURL
    }
    
    func addProject(_ token: String,_ project: ProjectAdd, completion: @escaping(Result<ProjectAdd, ProjectError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resource)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(project)
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        completion(.success(project))
                    }
                    if response.statusCode == 500 {
                        completion(.failure(ProjectError.networkError))
                    }
                }
            }.resume()
        
        } catch {
            completion(.failure(.otherError))
        }
    }
    
    func getAllProject(_ token: String, completion: @escaping(Result<[Project], ProjectError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resource)
            urlRequest.httpMethod = "GET"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                if let jsonData = data {
                    do{
                        let customers = try JSONDecoder().decode([Project].self, from: jsonData)
                        completion(.success(customers))
                    } catch {
                        completion(.failure(.networkError))
                    }
                }
            }.resume()
        }
    }
    
    func updateProject(_ token: String, _ project: ProjectAdd, completion: @escaping(Result<ProjectAdd, ProjectError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resource)
            urlRequest.httpMethod = "PUT"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(project)
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Body: \(urlRequest.httpBody)")
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    print("Response: \(response)")
                    if response.statusCode == 200 {
                        completion(.success(project))
                    }
                }
            }.resume()
        
        } catch {
            completion(.failure(.otherError))
        }
    }
    
    func deleteProject(_ token: String, completion: @escaping(Result<Project, ProjectError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resource)
            urlRequest.httpMethod = "DELETE"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                print("Response: \(response!)")
            }.resume()
        } catch {
            completion(.failure(.networkError))
        }
    }
}

