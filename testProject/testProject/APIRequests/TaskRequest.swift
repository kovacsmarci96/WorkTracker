//
//  TaskRequest.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 26..
//

import Foundation

enum TaskError: Error {
    case nameError
    case networkError
}


struct TaskRequest {
    let resource: URL
    
    init(projectId: String, endpoint: String) {
        let resourceString = "http://192.168.1.72:45455/\(projectId)/task/\(endpoint)"
        let resourceString2 = "http://192.168.1.72:45456/\(projectId)/task/\(endpoint)"
        let urlString = resourceString2.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let resourceURL = URL(string: urlString!) else {
            fatalError()
        }
        
        self.resource = resourceURL
    }
    
    func addTask(_ token: String,_ task: Task, completion: @escaping(Result<Task, TaskError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resource)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.httpBody = try JSONEncoder().encode(task)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        completion(.success(task))
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
    
    func getAllTask(_ token: String, completion: @escaping(Result<[Task], TaskError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resource)
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.httpMethod = "GET"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                if let jsonData = data{
                    do{
                        let tasks = try JSONDecoder().decode([Task].self, from: jsonData)
                        completion(.success(tasks))
                    } catch {
                        completion(.failure(.networkError))
                    }
                }
            }.resume()
        }
    }
    
    func getTaskHour(_ token: String, completion: @escaping(Result<Double, TaskError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resource)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                if let jsonData = data {
                    do {
                        let taskHour = try JSONDecoder().decode(Double.self, from: jsonData)
                        completion(.success(taskHour))
                    } catch {
                        completion(.failure(.networkError))
                    }
                }
            }.resume()
        }
    }
    
    func updateTask(_ token: String, _ task: Task, completion: @escaping(Result<Task, TaskError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resource)
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.httpMethod = "PUT"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(task)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        completion(.success(task))
                    }
                }
            }.resume()
        
        } catch {
            completion(.failure(.networkError))
        }
    }
    
    func deleteTask(_ token:String, completion: @escaping(Result<Task, TaskError>) -> Void) {
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
