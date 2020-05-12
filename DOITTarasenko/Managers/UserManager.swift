//
//  UserManager.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/11/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import RxSwift
import RxCocoa
import Moya

protocol UserManager {
    var user: User? { get }
    func signUp(mail: String, password: String) -> Observable<User>
    func login(mail: String, password: String) -> Observable<User>
    func removeToken()
    func handleApiError(data: Data) -> AppError?
}

class UserManagerImplementation: UserManager {
    private(set) var user: User?
    private var customKeychainWrapperInstance: KeychainWrapper?
    
    private struct Constans {
        static var token = "token"
        static var email = "email"
    }
    
    init() {
        receiveToken()
    }

    func signUp(mail: String, password: String) -> Observable<User> {
        return RequestsProvider.rx
            .request(.signUp(mail, password))
            .map { result -> User in
                if let error = self.handleApiError(data: result.data) {
                    throw error
                }
                var user = try User.decode(data: result.data)
                user.email = mail
                self.user = user
                self.saveToken(mail)
                return user
            }.asObservable()
    }
    
    func login(mail: String, password: String) -> Observable<User> {
        return RequestsProvider.rx
            .request(.login(mail, password))
            .map { result -> User in
                if let error = self.handleApiError(data: result.data) {
                    throw error
                }
                var user = try User.decode(data: result.data)
                user.email = mail
                self.user = user
                self.saveToken(mail)
                return user
            }.asObservable()
    }
    
    func removeToken() {
        KeychainWrapper.standard.removeObject(forKey: Constans.token)
        KeychainWrapper.standard.removeObject(forKey: Constans.email)
        user = nil
    }
    
    func handleApiError(data: Data) -> AppError? {
       do {
           guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
               else { return nil }
           var title = ""
           var description = ""
           if let messageDescription = json["message"] as? String {
               title = messageDescription
               if title == "Expired token" { return .expiredToken}
           }
           if let fieldsDescription = json["fields"] as? [String: Any] {
               description = fieldsDescription.map({ key, value in
                   let values = (value as! [String]).joined(separator: ", ")
                   return "\(key): \(values)"
                   }).joined(separator: ", ")
           }
           if title.isEmpty, description.isEmpty { return nil}
           return .custom("\(title). \(description)")
       } catch {
           return .custom(error.localizedDescription)
       }
    }
    
    private func saveToken(_ email: String) {
        guard let token = user?.token else { return }
        KeychainWrapper.standard.set(token, forKey: Constans.token)
        KeychainWrapper.standard.set(email, forKey: Constans.email)
    }
    
    private func receiveToken() {
        guard let token = KeychainWrapper.standard.string(forKey: Constans.token) else { return }
        let email = KeychainWrapper.standard.string(forKey: Constans.email)
        user = User(token: token, email: email)
    }
}
