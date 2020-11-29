//
//  RegisterRequest.swift
//  testProject
//
//  Created by Kovács Márton on 2020. 11. 25..
//

import Foundation
import JWTDecode

enum UserError: Error {
    case emailPasswordEmpty
    case nameEmpty
    case emailNotMatch
    case passwordNotMatch
    case emailAlreadyInUse
    case networkError
    case shortPassword
    case digitPassword
    case upperCase
    case invalidEmail
    case noError
    
    case noUser
    case wrongPassword
}
    


struct UserRequest {
    let resource: URL
    
    
    //RegisterErrors
    let emptyEmail = "Email and password cannot be empty."
    let nameError = "Name cannot be empty."
    let passwordNotMatch = "Password and confirmation doesnt match."
    let emailNotMatch = "Email and confirmation doesnt match."
    let shortPassword = "Passwords must be at least 6 characters."
    let digitPassword = "Passwords must have at least one digit ('0'-'9')."
    let upperCase = "Passwords must have at least one uppercase ('A'-'Z')."
    let invalidEmail = "invalid"
    let usedEmail = "Email already in use."
    
    //LoginErrors
    let noUser = "Cannot find user"
    let wrongPassword = "Wrong password"
    
    
    
    init(endpoint: String) {
        let resourceString = "http://192.168.1.72:45455/user/\(endpoint)"
        let resourceString2 = "http://192.168.1.72:45456/user/\(endpoint)"
        let urlString = resourceString2.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let resource = URL(string: urlString!) else {
            fatalError()
        }
        self.resource = resource
    }
    
    
    func checkRegisterResponse (_ responseString: String) -> UserError {
        if(responseString.contains(emptyEmail)) {
            return .emailPasswordEmpty
        }
        if(responseString.contains(nameError)) {
            return .nameEmpty
        }
        if(responseString.contains(passwordNotMatch)) {
            return .passwordNotMatch
        }
        if(responseString.contains(emailNotMatch)) {
            return .emailNotMatch
        }
        if(responseString.contains(shortPassword)) {
            return .shortPassword
        }
        if(responseString.contains(digitPassword)) {
            return .digitPassword
        }
        if(responseString.contains(upperCase)) {
            return .upperCase
        }
        if(responseString.contains(invalidEmail)) {
            return .invalidEmail
        }
        if(responseString.contains(usedEmail)) {
            return .emailAlreadyInUse
        }
        if(responseString.contains(invalidEmail)){
            return .invalidEmail
        }
        if(responseString.contains(invalidEmail)){
            return .invalidEmail
        }
        return .noError
    }
    
    func checkLoginResponse(_ responseString: String) -> UserError {
        if(responseString.contains(noUser)){
            return .noUser
        }
        if(responseString.contains(wrongPassword)){
            return .wrongPassword
        }
        return .noError
    }
    
    func registerUser(_ form: RegForm, completion: @escaping(Result<RegForm, UserError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resource)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(form)
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                print(String(data: data!, encoding: .utf8)!)
                if let responseString = String(data: data!, encoding: .utf8), let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        completion(.success(form))
                    }
                    if response.statusCode == 500 {
                        completion(.failure(.networkError))
                    }
                    if response.statusCode == 401 {
                        completion(.failure(checkRegisterResponse(responseString)))
                    }
                    if response.statusCode == 400 {
                        completion(.failure(checkRegisterResponse(responseString)))
                    }
                }
            }.resume()
        } catch {
            completion(.failure(.networkError))
        }
    }
    
    func loginUser(_ form: LoginForm, completion: @escaping(Result<User, UserError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resource)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(form)
            
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let jsonData = data, let response = response as? HTTPURLResponse, let responseString = String(data: data!, encoding: .utf8) {
                    do {
                        if response.statusCode == 200 {
                            let user = try JSONDecoder().decode(User.self, from: jsonData)
                            user.email = form.Email
                            completion(.success(user))
                        }
                        if response.statusCode == 401 {
                            completion(.failure(checkLoginResponse(responseString)))
                        }
                    } catch {
                        completion(.failure(.networkError))
                    }
                }
            }.resume()
        
        } catch {
            completion(.failure(.networkError))
        }
    }
    
    func getAllUser(_ token: String, completion: @escaping(Result<[User], WorkError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resource)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                print("Response: \(response)")
                if let jsonData = data {
                    do{
                        let users = try JSONDecoder().decode([User].self, from: jsonData)
                        completion(.success(users))
                    } catch {
                        completion(.failure(.networkError))
                    }
                }
            }.resume()
        }
    }

}
