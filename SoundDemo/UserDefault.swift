//
//  UserDefault.swift
//  SoundDemo
//
//  Created by ngocdm on 3/30/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit
let authToken = "authToken"
let userName = "userName"
let userType = "userType"

class UserDefault: NSObject {
    static let shared = UserDefault()
    
    func setToken(_ token: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(token, forKey: authToken)
        userDefaults.synchronize()
    }
    
    func getToken() -> String? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: authToken) as? String
    }
    
    func resetToken() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: authToken)
        userDefaults.synchronize()
    }
    
    func setUserName(_ name: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(name, forKey: userName)
        userDefaults.synchronize()
    }
    
    func getUserName() -> String? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: userName) as? String
    }
    
    func resetUserName() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: userName)
        userDefaults.synchronize()
    }
    
    func setUserType(_ type: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(type, forKey: userType)
        userDefaults.synchronize()
    }
    
    func getUserType() -> Int? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: userType) as? Int
    }
    
    func resetUserType() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: userType)
        userDefaults.synchronize()
    }
    
    func resetUserInfo() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: authToken)
        userDefaults.set(nil, forKey: userName)
        userDefaults.set(nil, forKey: userType)
        userDefaults.synchronize()
    }

}
